#!/bin/bash

abm=${1?No model executable specified}

# Check that the model executable exists.
if [ ! -f $abm ] ; then
	echo "The model executable '$abm' does not exist."
	exit 1300
fi

# Prepend "./" if needed: the executable name has no slashes,
# so it refers to an executable in the current directory (the typical case).
if [[ $abm =~ ^[^/]+$ ]] ; then
	abm="./"$abm
fi

echo $abm
