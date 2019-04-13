#!/bin/bash

# Generate a 4 byte unsigned integer.
# -A n: don't include a file offset in the output.
# -N 4: grab 4 bytes from /dev/urandom
# -t u4: output an unsigned 4 byte integer.
# sed: delete any leading blanks. Needed for seeds directly written to a seed file.
od -A n -N 4 -t u4 /dev/urandom | sed 's# ##g'
