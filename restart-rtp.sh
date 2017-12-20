#!/bin/bash
# restart CP2K multiple trajectory RTP dynamics
#launch this in supdirectory containing TRAJ.X folders
folder=frankPBE        # Name of the folder with trajectories
ntrajs=5              # number of trajectories 
projectname=DIMER      # projectname
TASKPERJOB=3           # How many simulataneous tasks will be executed within one qsub file
NJOBS=16               # Number of submited files
NPROCS=8               # $CPUs per mpirun -np switch
#QSUB PBS SETTINGS------------------
queue=qlong             # Avaible ques: qprod qlong qexp qfree
walltime=144:00:00      # The maximum runtime in qlong is 144 hours, qprod is 48 hours,  qexp is 1 hour
PATCHED=unpatched
runtype=RTP_RESTART_1

cd $folder
TRAJSDIR=$PWD

#preparing simulataneous submitable script
for ((k=1;k<=$NJOBS;k++))
do

cat > $projectname.$runtype.$k.sh << EOF
#!/bin/bash
#PBS -q $queue
#PBS -l select=1:ncpus=24:mpiprocs=24:mem=96gb
#PBS -l walltime=$walltime
#PBS -A OPEN-10-48
#PBS -e ERROR_$projectname.$runtype.$k.sh

EOF
done

k=1      # .sh script
ITRAJ=1  #TRAJ

for ((ITRAJ=1;ITRAJ<=$ntrajs;ITRAJ++))
do
cd TRAJ.$ITRAJ/RTP
echo "Working in:  $PWD"
logfile=$(ls *log | head -1)
SCRDIR=$(head -3 $logfile | tail -1)
KDE=$(head -4 $logfile  | tail -1)

echo "Logfile: $logfile"
echo "Final folder: $KDE"
#echo "Copy done in TRAJ.$k---------------------------------"

cd $SCRDIR
echo "Checking for latest  restart file in $PWD"

for STEP in {70000..120000..500}
  do 
    if [[ -e "DIMER_$ITRAJ-RESTART-1_$STEP.rtpwfn" ]]; then
    echo "File DIMER_$ITRAJ-RESTART-1_$STEP.rtpwfn EXISTS"
     latest=$STEP
    fi
    
done
echo "Last restart is: $latest"
#copy backup
# file name depends on projectname in launchCP2ks-dynamics
cp  $SCRDIR/DIMER_$ITRAJ-pos-1.xyz                 $KDE
cp  $SCRDIR/DIMER_$ITRAJ-1.ener                    $KDE
cp  $SCRDIR/DIMER_$ITRAJ-RESTART-1_$latest.rtpwfn  $KDE
cp  $SCRDIR/DIMER_$ITRAJ-1_$latest.restart         $KDE
cp  $SCRDIR/DIMER_$ITRAJ-1.restart                 $KDE
cp  $SCRDIR/DIMER_$ITRAJ-RESTART.rtpwfn            $KDE
cp  $SCRDIR/*.bak*                                 $KDE
cp  $SCRDIR/*.out                                  $KDE

cd $TRAJSDIR/TRAJ.$ITRAJ/
echo "Working now in $PWD." 
echo "Creating dir and cp file for restart"

if [[ -d "RTP_RESTART_1" ]]; then
rm -r RTP_RESTART_1; mkdir RTP_RESTART_1
else
mkdir RTP_RESTART_1
fi

cp  RTP/DIMER_$ITRAJ-pos-1.xyz                RTP_RESTART_1/.
cp  RTP/DIMER_$ITRAJ-1.ener                   RTP_RESTART_1/.
cp  RTP/DIMER_$ITRAJ-RESTART.rtpwfn           RTP_RESTART_1/.
cp  RTP/DIMER_$ITRAJ-1.restart                RTP_RESTART_1/RTP_RESTART1.inp

cd RTP_RESTART_1
ls 

cd ../..

#Simultaneous jobs in one file 
echo "(cd $TRAJSDIR/TRAJ.$ITRAJ/$runtype/; ./r.$runtype.$ITRAJ ) &">> $TRAJSDIR/$projectname.$runtype.$k.sh

if [[ `expr $ITRAJ % $TASKPERJOB` -eq 0 ]]; then
 let k++
fi

done

echo "DONE WITH PREPARING RESTART FOLDERS. Waiting."
wait 10s

cd $TRAJSDIR
k=1
for ((k=1;k<=$NJOBS;k++))
do
   if [[ -f "$projectname.$runtype.$k.sh" ]];then
      echo "wait" >> $projectname.$runtype.$k.sh     # whille all parallel jobs running, wait until the very last traj is done
      echo "Submiting: $projectname.$runtype.$k.sh"
      chmod +x $projectname.$runtype.$k.sh
     # qsub $projectname.$runtype.$k.sh
   fi

done