This set of files contains somewhat stripped down versions of scripts used by
the Kirschner-Linderman research group for submitting batch jobs on a variety
of systems.

They support both the PBS and SLURM batch systems transparently.

They are designed for systems that allocate individual cores. That is, a batch
job can use a single core and multiple single-core batch jobs can run on the
same node. For example, the UM Flux cluster.

There are 2 top level scripts, lhssubmit-job-array and
lhssubmit-job-array-runlist, and several support scripts which are called,
directly or indirectly by the top level scripts. 

All the scripts are Bash scripts, Bash being a widely used Linux shell
(terminal window command interface). A Bash script can contain system commands,
which are run as if they were entered manually in a terminal window, and flow
control statements, such as assignment statements, integer arithmetic, if
statements, while loops, for loops, etc.

The Bash script language syntax is somewhat arcane compared to a typical
computer language, such as Java, JavaScript, Perl, Python, etc. It is defined
to be convenient for running programs from a script.

The 2 top level scripts are designed for performing large parameter sweeps of
custom agent based models written in C++, typically anyhwere from hundreds to
tens of thousands of model runs. The scripts make assumptions about model
command line options, input data files, etc. that won't match other type of
runs you may need to do. They also assume a particular directory structure for
storing the model run results which may not match the needs of your batch runs.

Our parameter sweeps sample parameter space using a technique called LHS (Latin
Hypercube Sampling), so we often refer to a parameter sweep as an LHS. The
script comments often do this as well.

Since our models are stochastic (use random numbers from a random number
generator at various model/code decision points) there are 1 or more runs
performed with each parameter file each with a different random number seed.

We refer to all the runs with a parameter file as an experiment and a run with
the same parameter file but a different random number seed as a replication.
The experiments are numbered from 1 to E and the replications are numbered from
1 to R. The parameter files are XML files named 1.xml, ..., E.xml.

Both top level scripts work in a very similar manner.

lhssubmit-job-array is for performing a sweep for a range of experiments and a
range of replications, almost always 1 to E and 1 to R, respectively.
 
lhssubmit-job-array-runlist is for running a subset of runs, specified in a run
list file. Each line of the run list file specifies one combination of
experiment and replication to run. This is useful for running a subset of a
prior sweep, where some of the runs meet some criteria, such as matching
experimental data, and further runs are warranted.

Both top level scripts determine what the local batch system is, PBS or SLURM,
check their command line options for validity and then iterate over the runs to
be performed, bundling them into a series of job array batch jobs. The
appropriate batch submission command is then used for the local batch system
(qsub for PBS, sbatch for SLURM).

lhssubmit-job-array iterates over the runs using the experiment range and
replication range.

lhssubmit-job-array-runlist iterates over the runs using the experiments and
replications in the run list file.

For both PBS and SLURM a job array is an efficient way to submit several batch
jobs with one submission command, especially for large parameter sweeps. When
each batch job is run the batch system defines an environment variable that
specifies the job array index for that batch job - 1 for the first job in the
job array, 2 for the 2nd, etc.

The same batch script, PBS script or SLURM script, is used for each individual
batch job in a job array. We use lhs-qsub-job-array.pbs for PBS and
lhs-sbatch-job-array.slurm for SLURM.

While iterating over the runs, the submission scripts create the command line
for that run and append it as a separate line to the end of a file called
paramList. The command line includes the model executable to run (which is the
same for all the runs), the command line options that specify the input file to
use, the random number seed, the output directory where the run results should
be written and any other command line options to use (also the same for all the
runs in the sweep).

When a batch job is taken off the input queue and starts executing, it uses its
job array index to choose which line of the paramList file to use for that run.

The actual circumstances are a bit more complicated. Sometimes a single run is
so short it makes sense for each batch job to do multiple runs, so both
submission scripts have a command line option to specify the number of model
runs per individual batch job.

This makes the computation of how many runs to bundle into a batch job array
more complicated and also complicates the information needed and the
calculation for what lines of the paramList file each individual batch job
should use.

The submission scripts create 3 additional files:

submission-command-history: The submission scripts append the submission
                            script command line to this file, so it can
                            easily be re-run again if some runs did not
                            finish within the job wall time limit.

job-id: The batch job id of each job array job that was submitted.

job-command: The qsub or sbatch command used to submit the job array jobs.

Our models all write a zero length file called runCompleted in run's result
directory whenever a model successfully completes. The submission scripts
ignore any run which has a runCompleted file. If some runs didn't finish, due
to needing longer than the job wall time limit, or less likely due to some
failure of the computer system, the exact same submission command can be rerun
and only the uncompleted jobs will be submitted. The submission command can be
copied and pasted from the submission-command-history file.  Our models also
have a checkpoint capability (the --restart-interval command line option) so
the resubmitted jobs will start from their most recent checkpoint.

*********
Example 1
*********

lhssubmit-job-array gr 1 500 1 3 002:00:00 lung-model-options-short.sh 1 FAN-1234

gr: The model executable.

1: The starting experiment. This almost always 1.

500: The ending experiment. 500 is a common number for our runs.

1: The starting replication. This is almost always 1.

3: Then ending replication. Common values are 3, 5 and 10.

002:00:00: The wall time limit to use. This specifies 2 hours. This varies
           greatly depending on the model being run and the model options.

lung-model-options-short.sh: A Bash script whose output is a string that is the
                             model options for the executable, in the same form
                             as would be typed by a user in a terminal window.
                             It must not include the model options added by a
                             submission script, such as for the parameter file
                             to use, the output directory, the random number
                             seed, etc

1: How many model runs per individual batch job. 1 is usual.

FAN-1234: A Flux Account Number, when running on Flux. We actually haven't
          run on Flux for several years and the systems we do run on do
          not require an account number, so we leave this off for our runs.

500 experiments, with 3 replications per experiment is 1500 total runs. This
would create a paramList file with 1500 lines. On the PBS systems we use, which
have no limit on the size of a job array, this would submit 1 job array batch
job for all 1500 runs. On the SLURM system we use (the XSEDE Comet system at
UCSD), which has a limit of 1000 jobs in a job array, this would still create a
single paramList file with 1500 lines and would submit 2 job array batch jobs,
the first with 1000 individual batch jobs and the 2nd with 500. The jobs in the
1st job array would use the 1st 1000 lines of the paramList file.  The jobs in
the 2nd job array would use the last 500 lines of the paramList file.

The paramList file would have lines like:
/usr/bin/time --append -o exp1/exp1-1/runtime -f \"%e\" ./gr --dim 200 --days 200 --state-interval 7200 --stats --moi --csv-interval 144 --restart-interval 7200 > exp1/exp1-1/stdout 2>&1
/usr/bin/time --append -o exp1/exp1-2/runtime -f \"%e\" ./gr --dim 200 --days 200 --state-interval 7200 --stats --moi --csv-interval 144 --restart-interval 7200 > exp1/exp1-2/stdout 2>&1
/usr/bin/time --append -o exp2/exp2-1/runtime -f \"%e\" ./gr --dim 200 --days 200 --state-interval 7200 --stats --moi --csv-interval 144 --restart-interval 7200 > exp2/exp2-1/stdout 2>&1
/usr/bin/time --append -o exp2/exp2-2/runtime -f \"%e\" ./gr --dim 200 --days 200 --state-interval 7200 --stats --moi --csv-interval 144 --restart-interval 7200 > exp2/exp2-2/stdout 2>&1
.
.
.
/usr/bin/time --append -o exp500/exp500-1/runtime -f \"%e\" ./gr --dim 200 --days 200 --state-interval 7200 --stats --moi --csv-interval 144 --restart-interval 7200 > exp500/exp500-1/stdout 2>&1
/usr/bin/time --append -o exp500/exp500-2/runtime -f \"%e\" ./gr --dim 200 --days 200 --state-interval 7200 --stats --moi --csv-interval 144 --restart-interval 7200 > exp500/exp500-2/stdout 2>&1
/usr/bin/time --append -o exp500/exp500-3/runtime -f \"%e\" ./gr --dim 200 --days 200 --state-interval 7200 --stats --moi --csv-interval 144 --restart-interval 7200 > exp500/exp500-3/stdout 2>&1

*********
Example 2
*********

lhssubmit-job-array-runlist gr runlist 002:00:00 lung-model-options.sh 1 FAN-1234

This is the same as the prior example but the runs to perform are in file runlist,
which might have the following contents, to perform 3 specific runs:
84 3
97 1
117 2

This would create a paramList file with 3 lines and submit one job array job
for the 3 runs.

The paramList file would be:
/usr/bin/time --append -o exp84/exp84-3/runtime -f \"%e\" ./gr --dim 200 --days 200 --state-interval 7200 --stats --moi --csv-interval 144 --restart-interval 7200 > exp84/exp84-3/stdout 2>&1
/usr/bin/time --append -o exp97/exp97-1/runtime -f \"%e\" ./gr --dim 200 --days 200 --state-interval 7200 --stats --moi --csv-interval 144 --restart-interval 7200 > exp97/exp97-1/stdout 2>&1
/usr/bin/time --append -o exp117/exp117-2/runtime -f \"%e\" ./gr --dim 200 --days 200 --state-interval 7200 --stats --moi --csv-interval 144 --restart-interval 7200 > exp117/exp117-2/stdout 2>&1


