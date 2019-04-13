#!/bin/bash

# Some of the job submission scripts create a job-id file with the job ids of
# the submitted jobs. This is done by redirecting the output of a batch job
# submission command to the job-id file. This causes the file to have other
# text in addition to the job ids.

# Change the job-id file to only have job ids, no other text, so it's easier to
# use it for managing the jobs - getting their status, canceling, etc.

# There won't be a job-id file if the submission script was run in a test mode,
# we are using one of the test queues, and so not submitting any jobs.

if [[ -f job-id ]]; then
	mv job-id job-id.bak
	awk '{print $NF}' job-id.bak > job-id
	rm job-id.bak
fi

