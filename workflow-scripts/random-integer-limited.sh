#!/bin/bash

# Get a random unsigned integer that is no larger than the largest positive
# value of a 4 byte signed integer.

# This addresses a limitation of the Qt QSpinbox widget, which only displays
# signed integers.  For random number generator seed values, we want unsigned
# values, but no bigger than the maximum signed int that a Qt QSpinbox can
# display.

maxuint="2147483647"
result=0
while (( result == 0 ))
do
	uint=`randomInteger.sh`
	(( result = uint <= maxuint ))
done 
echo $uint
