#!/bin/bash

# Get the suffix of the specified length of the specified string.  The suffix
# must begin the an alphabetic character. This is for use as the name of a job
# submitted to PBS (Portable Batch System).

str=${1?"$0: no string specified"}
suffixLength=${2?$0:no string suffix length specified}

strlen=${#str}

suffix=$str
if (( strlen > suffixLength )); then
	# Bash offsets are 0 based: 1st char is offset 0, etc.
	(( offset = strlen - suffixLength ))
	suffix=${str:offset:suffixLength}
fi

# Delete non-alpha characters.
shopt -s extglob
suffix=${suffix//+([^[:alpha:]])}
echo "$suffix"
