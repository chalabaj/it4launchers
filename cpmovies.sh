#!/bin/bash

for ((k=1;k<=47;k++))
do
cd TRAJ.$k/RTP
echo $PWD
logfile=$(ls *log | head -1)
echo $logfile
SCRDIR=$(head -3 $logfile | tail -1)
KDE=$(head -4 $logfile  | tail -1)
echo "SCRATCH: $SCRDIR"
echo "Final folder: $KDE"
echo "Copy done in TRAJ.$k---------------------------------"
echo "  "
cp  $SCRDIR/DIMER_$k-pos-1.xyz $KDE/.
cp  $SCRDIR/DIMER_$k-1.ener $KDE/.

cp  $SCRDIR/DIMER_$k-pos-1.xyz ../../eners-movies/.
cp  $SCRDIR/DIMER_$k-1.ener ../../eners-movies/.

#fetch.sh $logfile
cd ../..
done