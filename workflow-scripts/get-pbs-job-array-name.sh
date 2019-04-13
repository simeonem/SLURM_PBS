#!/bin/bash

# Construct a name for a PBS job array job, given a batch job ordinal (since
# more than one batch job with job arrays can be submitted for an LHS).

# If possible use the tail end of the LHS directory name (the current
# directory) for a job name prefix, otherwise use a fixed job name prefix.
#
# This is also used for generating job names for the SLURM batch system,
# using the same constraints as for PBS.

suffix=${1?"$0: No batch job ordinal was specified"}
suffixLen=${#suffix}

# PBS job names can be at most 15 characters long.
if (( suffixLen >= 15)); then
	# Prefix takes up the entire 15 characters or more.
	# Make the 1st character alphabetic and truncate to 15 characters.
	jobName="J${suffix:0:14}"
else
	prefixMaxLen=$(( 15 - suffixLen ))
	prefix=$(sh get-string-suffix.sh $PWD $prefixMaxLen)

	# If prefix is empty, use "J".
	jobName=${prefix:-J}${suffix}
fi

echo "$jobName"

