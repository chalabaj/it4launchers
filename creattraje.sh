#!/bin/bash

#---------------------------------------------------------------------------------
#  Create_Trajectories                   Daniel Hollas, Ondrej Svoboda 2016

# This script generates and executes a set of dynamical trajectories using ABIN.
# Initial geometries are taken sequentially from a XYZ movie file.
# Initial velocities are optiononaly taken sequentially from a XYZ file.

# The script is designed both for surface hopping and adiabatic AIMD.

# The trajectories are executed and stored in $folder.

# Files needed in this folder:
#	$inputdir : template directory with ABIN input files (mainly input.in and r.abin)
# 	traj-randomint PRNG program should be in your $PATH.
#---------------------------------------------------------------------------------

#######-----SETUP---#############
irandom0=156863189      # random seed, set negative for random seed based on time
movie=geoms.xyz          # PATH TO a XYZ movie with initial geometries
veloc=                  # PATH to XYZ initial velocities, leave blank if you do not have them
isample=1	              # initial number of traj
nsample=19	            # number of trajectories
folder=testlaunch       # Name of the folder with trajectories
inputdir=inputsdir
templatedir=TEMPLATE-$folder   # Directory with input files for ABIN
abin_input=$inputdir/input.in   # main input file for ABIN
launch_script=$inputdir/r.abin	# this is the file that is submitted by qsub
submit="qsub -q nq -cwd  " # comment this line if you don't want to submit to queue yet
rewrite=1            # if =1 -> rewrite trajectories that already exist
injob=6              # trajs per job
pwd=$(pwd)
#SALOMON PBS-------------------#
queue=qexp             # Avaible ques: qprod qlong qexp qfree
walltime=01:00:00      # The maximum runtime in qlong is 144 hours, qprod is 48 hours,  qexp is 1 hour
mem=24                 # memory - just enough for molpro, each core 1 gb
#------------------------------#

# Number of atoms is determined automatically from input.in
natom=$(awk -F"[! ,=]+" '{if($1=="natom")print $2}' $abin_input) #number of atoms
molname=$folder      # Name of the job in the queue
##########END OF SETUP##########
cp -r $inputdir $templatedir

function Folder_not_found {
   echo "Error: Folder $1 does not exists!"
   exit 1
}

function File_not_found {
   echo "Error: File $1 does not exists!"
   exit 1
}

function Error {
   echo "Error from command $1. Exiting!"
   exit 1
}

if [[ ! -d "$inputdir" ]];then
   Folder_not_found "$inputdir"
fi

if [[ ! -f "$movie" ]];then
   File_not_found "$movie"
fi

if [[ ! -z "$veloc" ]] && [[ ! -f "$veloc" ]];then
   File_not_found "$veloc"
fi

if [[ ! -e $abin_input ]];then
   File_not_found "$abin_input"
fi

if [[ ! -e "$launch_script" ]];then
   File_not_found "$launch_script"
fi

if [[ -e "mini.dat" ]] || [[ -e "restart.xyz" ]];then
   echo "Error: Files mini.dat and/or restart.xyz were found here."
   echo "Please remove them."
   exit 1
fi

#   -------------------------------------------------------------------------------------

echo "Number of atoms = $natom"

let natom2=natom+2
lines=$(cat $movie | wc -l)
geoms=$(expr $lines / $natom2)
if [[ $nsample -gt $geoms ]];then
   echo "ERROR: Number of geometries ($geoms) is smaller than number of samples($nsample)."
   echo "Change parameter \"nsample\"."
   exit 1
fi

# I don't think this is needed, we make sure not to overwrite any trajectory anyway
#if [[ -e $folder/$molname.$isample.*.sh ]];then
#   echo  "Error: File $folder/$molname.$isample.*.sh already exists!"
#   echo "Please, make sure that it is not currently running and delete it."
#   exit 1
#fi


#--------------------generation of random numbers--------------------------------
echo "Generating $nsample random integers."
$inputdir/MyIrandom $irandom0 $nsample > iran.dat
if [[ $? -ne "0" ]];then
   Error "trajs-randomint"
fi

#--------------------------------------------------------------------------------

if [[ -d "$folder" ]];then
      if [[ "$rewrite" -eq "1" ]];then
         rm -r $folder ; mkdir -p $folder
      else
         echo "Trajectory number $i already exists!"
         echo "Exiting..."
         exit 1
      fi

else
     mkdir -p $folder
fi

cp iseed0 "$abin_input" $folder


j=1
i=$isample

#SUBMIT SCRIPT WITH PARALELEL RUNS for first submit $j-file
cat > $folder/$molname.$isample.$j.sh << EOF
#!/bin/bash
#PBS -q $queue
#PBS -l select=1:ncpus=24:mpiprocs=24:mem=${mem}gb:ompthreads=1
#PBS -l walltime=$walltime
#PBS -A OPEN-11-34
#PBS -V
EOF


let offset=natom2*isample-natom2

while [[ $i -le "$nsample" ]];do

   mkdir $folder/TRAJ.$i
   let offset=offset+natom2     
   cp -r $inputdir/* $folder/TRAJ.$i
   #chmod +x $folder/TRAJ.$i/MOLPRO/r.molpro

#--Now prepare mini.dat (and possibly veloc.in)

   head -$offset $movie | tail -$natom2 > geom
   if [[ ! -z "$veloc" ]];then
      head -$offset $veloc | tail -$natom2 > veloc.in
   fi

   mv geom $folder/TRAJ.$i/mini.dat

   if [[ ! -z "$veloc" ]];then
      mv veloc.in $folder/TRAJ.$i/
   fi


## Now prepare input.in and r.abin
   irandom=`head -$i iran.dat |tail -1`

   sed -r "s/irandom *= *[0-9]+/irandom=$irandom/" $abin_input > $folder/TRAJ.$i/input.in 

   cat > $folder/TRAJ.$i/r.$molname.$i << EOF
#!/bin/bash
JOBNAME=ABIN.$molname.${i}_${PBS_JOBID}
INPUTPARAM=input.in
INPUTGEOM=mini.dat
OUTPUT=output
TRAJ=$i
EOF

   if [[ ! -z $veloc ]];then
      echo "INPUTVELOC=veloc.in" >> $folder/TRAJ.$i/r.$molname.$i
   fi

   grep -v -e '/bin/bash' -e "JOBNAME=" -e "INPUTPARAM=" -e "INPUTGEOM=" -e "INPUTVELOC=" $launch_script >> $folder/TRAJ.$i/r.$molname.$i

   chmod 755 $folder/TRAJ.$i/r.$molname.$i

echo "(cd $pwd/$folder/TRAJ.$i; ./r.$molname.$i ) &">> $folder/$molname.$isample.$j.sh

#--Distribute calculations after 6th traje jobs for queue

   if [[ $(expr $i % $injob) -eq 0 ]] && [[ $i -lt $nsample ]]; then
      let j++
      echo $i
      echo $j
      echo $(expr $i % $injob)
      

cat > $folder/$molname.$isample.$j.sh << EOF
#!/bin/bash
#PBS -q $queue
#PBS -l select=1:ncpus=24:mpiprocs=24:mem=${mem}gb:ompthreads=1
#PBS -l walltime=$walltime
#PBS -A OPEN-11-34
#PBS -V
EOF
   fi
#---------------------------------------------------------------------------

   let i++

done

# Submit jobs
k=1
if [[ ! -z "$submit" ]];then
   cd $folder
   while [[ $k -le $j ]]
   do
      if [[ -f $molname.$isample.$k.sh ]];then
         echo "wait" >> $molname.$isample.$k.sh     # whille all parallel jobs running, wait until the very last traj is done
         chmod +x $molname.$isample.$k.sh
        #$submit -V -cwd $molname.$isample.$k.sh
      fi
      let k++
   done
fi

