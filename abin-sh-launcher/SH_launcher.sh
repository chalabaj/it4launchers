#/bin/bash
# launcher for SH dnyamics at IT4i systems
ntrajs=$1    # number of trajs in folder
folder=$2    # where are the trajs
queue=$3      # which qu to use for calcs
walltime=$4   # depends on the selected que

mem=$(($nproc*1)) # 1 gb per core, depends on electronic structure demans, molpro is ussually low for CASSCF calcs.
#which queue  #qexp qprod

#if [ "$queue" -ne "qprod" -o "$queue" -ne "qprod" -o "$queue" -ne "qlong" ]; then
#echo "error: unknown que, use qprod or qexp for testing"
#PrintHelp
#fi

# CREATE file which is sent to the que
cat > r.$name << EOF
#!/bin/bash

#PBS -q $queue
#PBS -N $name.out
#PBS -l select=1:ncpus=24:mpiprocs=24:mem=${mem}gb:ompthreads=1  # MPIPROC is require so tha molpro runs in parallel
#PBS -l walltime=$walltime
#PBS -A OPEN-11-34   # name of project with allocated cpuhours

for trajs echo "mpirun
MOLPROs $input $nproc 
EOF

echo "Submitting Molpro job for parallel execution in ${queue} queue with ${nproc} processes."

qsub r.$name




$MPIRUN -np $nproc --hostfile $PBS_NODEFILE $MOLPROEXE < $INPFILE >> ${LOGFILE} 
