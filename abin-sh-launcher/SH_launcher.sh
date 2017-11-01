#/bin/bash
ntrajs=$1    #number of trajs in folder
folder=$2    #where are the trajs
queue=$3
walltime=$4

mem=$(($nproc*1))
#which queue  #qexp qprod

#if [ "$queue" -ne "qprod" -o "$queue" -ne "qprod" -o "$queue" -ne "qlong" ]; then
#echo "error: unknown que, use qprod or qexp for testing"
#PrintHelp
#fi



cat > r.$name << EOF
#!/bin/bash

#PBS -q $queue
#PBS -N $name.out
#PBS -l select=1:ncpus=24:mpiprocs=24:mem=${mem}gb:ompthreads=1
#PBS -l walltime=$walltime
#PBS -A OPEN-11-34

for trajs echo "mpirun
MOLPROs $input $nproc 
EOF

echo "Submitting Molpro job for parallel execution in ${queue} queue with ${nproc} processes."

qsub r.$name




$MPIRUN -np $nproc --hostfile $PBS_NODEFILE $MOLPROEXE < $INPFILE >> ${LOGFILE} 