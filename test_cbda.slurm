#!/bin/bash

umask 007

echo "Running on: ${SLURM_CLUSTER_NAME}, node list: ${SLURM_JOB_NODELIST}, node names: ${SLURMD_NODENAME} in: `pwd` at `date`"
echo "SLURM_NTASKS: ${SLURM_NTASKS} SLURM_TASKS_PER_NODE: ${SLURM_TASKS_PER_NODE} "
echo "SLURM_ARRAY_TASK_ID: ${SLURM_ARRAY_TASK_ID}"

