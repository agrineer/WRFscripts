# edit test.sh to your environment

To test the mpi and slurm implementation:
$ make
$ sbatch test.sh
$ cat mpitest.out

To test in local MPICH:
$ mpiexec -n 4 ./mpi_hello_world

To get information on the run, set:
$ export MPIR_CVAR_DEBUG_SUMMARY=1

and rerun.

To test mpd.hosts:
$ mpiexec -machinefile ~/mpd.hosts ./mpi_hello_world
