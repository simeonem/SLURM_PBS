#!/bin/bash

# This script assumes it was invoked from the main LHS directory.

# Set the file permission mask so that all files created by this script
# have permissions rw-rw---- and directories have permissions rwxrwx---.
umask 007

# By default the initial directory for a SLURM job is the directory the job was
# submitted from (the directory where the sbatch command was executed from).

# Program output is written directly to the result directory, not to the compute node
# scratch space.

# Blank line between output from separate invokations of this script due to preemption.
echo
echo "=============================================================="

if [[ -z "$paramListFile" ]]; then
	echo "Aborting: The paramList file name in environment variable paramListFile is empty."
	exit 1
fi

if [[ ! -f "$paramListFile" ]]; then
	echo "Aborting: The paramList file of '$paramListFile' doesn't exist."
	exit 1
fi

echo "Running on: ${SLURM_CLUSTER_NAME}, node list: ${SLURM_JOB_NODELIST}, node names: ${SLURMD_NODENAME} in: `pwd` at `date`"
echo "SLURM_NTASKS: ${SLURM_NTASKS} SLURM_TASKS_PER_NODE: ${SLURM_TASKS_PER_NODE} "
echo "SLURM_ARRAY_TASK_ID: ${SLURM_ARRAY_TASK_ID}"

# Do the runs for this batch job, based on the job array index and the number
# of runs per job. We do each run sequentially. When runs per job > 1 this is
# to use at least 1 hour of compute time for short runs, since on the XSEDE
# Comet system the minimum charge is 1 hour.
idx=${SLURM_ARRAY_TASK_ID}

# Because of an issue on the XSEDE Comet system, all job arrays are in the
# range 1-N, where N is MaxJobArraySize, except for the last job array batch
# job in a set of job array batch jobs, where N might be, and typically will
# be, less than MaxJobArraySize.

# The last run of the prior job array.
(( priorEndRun = runsPerJob * MaxJobArraySize * (batchJobOrdinal - 1) )) 
(( startRun = priorEndRun + (idx - 1) * runsPerJob + 1))

(( endRun = priorEndRun + idx * runsPerJob ))

# The last job in the job array might not have runsPerJob runs, so limit endRun
# to the number of lines in the paramList file.
totalRunCount=`wc -l $paramListFile | cut -d" " -f1`
if (( endRun > totalRunCount )); then
	endRun=$totalRunCount
fi

echo "Doing runs $startRun to $endRun"
for (( run = startRun; run <= endRun; ++run))
do
	# Get the command to run from the paramList file.
	cmd=`sed -n "${run}p" $paramListFile`
	
	echo "Run: $run"
	echo "cmd: $cmd"
	
	if [[ -z "$cmd" ]]; then
		echo "No command found in paramList file '$paramListFile' for job array index '$run'."
		continue
	fi
	
	# $cmd by itself won't work. The model executable will complain about
	# invalid command line arguments.
	eval $cmd || echo "ERROR running model..." 1>&2;
done

# Get the run time of this script, to a resolution of 1 second.
echo "Runtime $SECONDS"
