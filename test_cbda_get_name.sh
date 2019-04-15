suffix=${1?"$0: No batch job ordinal was specified"}
suffixLen=${#suffix}

# PBS job names can be at most 15 characters long.
if (( suffixLen >= 15)); then
	# Prefix takes up the entire 15 characters or more.
	# Make the 1st character alphabetic and truncate to 15 characters.
	jobName="J${suffix:0:14}"
else
	prefixMaxLen=$(( 15 - suffixLen ))

	# If prefix is empty, use "J".
	jobName="${suffix}"
fi

echo "$jobName"
