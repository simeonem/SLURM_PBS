#!/bin/bash

# Check a model options file - that it exists, that it has been edited and that
# it does not have model options that should only be managed by a submission
# script.

modelOptionsFile=${1?No model options file specified}

if [[ ! -f $modelOptionsFile ]] ; then
	echo "model options file '$modelOptionsFile' doesn't exist"
	 exit 800
fi

# Check that the "exit" and associated "echo" commands have been deleted from
# the model options file.
if grep -q "#\s*DELETE" $modelOptionsFile ; then
	echo -e "\nYou need to edit the run options in the model options file '$modelOptionsFile' and delete any lines marked with '# DELETE'!\n"
	exit 1000
fi


# Get the command line options from the model options file.
modelOptions=`./$modelOptionsFile`
modelOptionsResult=$?

if (( modelOptionsResult != 0 )); then
	echo "The model options script file failed with exit status $modelOptionsResult:"
	echo "$modelOptions"
	exit 1100
fi

if [[ -z $modelOptions ]]; then
	echo "The model options are empty"
	exit 1105
elif [[  $modelOptions =~ "-o "|"--output-dir " ]]; then
	echo "Model options contain '-o' or '--output', which is handled by the submission scripts and should not appear in the model options file"
	exit 1110
elif [[  $modelOptions =~ "-i "|"--input-file " ]]; then

	# If there are submodel options, it's might be ok to have a -i option - the
	# main model might not have any varying parameters, so all runs in an LHS
	# might use the same main model parameter file. So we allow it in this
	# case.
	if [[ ! $modelOptions =~ "submodel-options-file" ]]; then
		echo "Model options contain '-i' or '--input-file', and no submodel options file specified."
		echo "'-i' is handled by the submission scripts and should not appear in the model options file,"
		echo "unless submodel options that use experiment specific parameter files are also specified."
		exit 1120
	fi

	submodelOptionsFile=$(is-submodel-exp-specific.sh $modelOptionsFile)
	if (( $? > 1 )); then
		echo $submodelOptionsFile
		exit 1122
	fi

	if [[ -z $submodelOptionsFile ]]; then
		echo "Model options contain '-i' or '--input-file', and the submodel options file specified"
		echo "does not use an experiment specific parameter file."
		echo "'-i' is handled by the submission scripts and should not appear in the model options file,"
		echo "unless submodel options that use experiment specific parameter files are also specified."
		exit 1124
	fi

elif [[  $modelOptions =~ "-s "|"--seed " ]]; then
	echo "Model options contain '-s' or '--seed', which is handled by the submission scripts and should not appear in the model options file"
	exit 1130
elif [[  $modelOptions =~ "--lhs " ]]; then
	echo "Model options contain '--lhs', which is handled by the submission scripts and should not appear in the model options file"
	exit 1130
fi
