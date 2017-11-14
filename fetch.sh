#!/bin/bash
# Simple script that fetches data from scratch to the current working directory.
# Expects the presence of file job.log created by r.abin.
if [[ -n "$1" ]]; then
	echo "log file found: $1"
	SCRDIR=$(head -3 $1 | tail -1)
	echo "SCRATCH: $SCRDIR:"
        KDE=$(tail -2 $1 | head -1)
	echo "Final folder $KDE" 
	echo "COPYING FILE"
	cp -r $SCRDIR $KDE/.
	echo "COPYING FINISHED"
elif [[ -e job.log ]];then
	echo "Job.log file found"
	NODE=$(head -1 job.log)
	JOB=$(tail -1 job.log)
	KDE=`pwd`i
	cp -r -u -p $JOB/* $KDE
else
	echo "ERROR: file job.log does not exist. Exiting now..."
  	exit 1
fi

