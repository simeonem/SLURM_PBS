#!/bin/bash

# A script that specifies the model options for the lung model.
# It must write a single string containing the model options to standard output.

# You can test this script by running it from the command line:
# ./lung-model-options-short.sh ; echo

# Do not include any of the following model options, as they are included by
# run submission scripts that invoke this script. Including them here will
# cause a fatal error when the model runs.
#
# -i, --input-file
# -o, --output-dir
# -s, --seed

# Exit immediately if an error occurs, such as an invalid assignment statement.
set -e

# Model run options. Edit as needed.

# Typical lung model options.
modelOptions="--dim 200 --days 200 --state-interval 7200 --stats --moi --csv-interval 144 --restart-interval 7200"

echo -n $modelOptions


