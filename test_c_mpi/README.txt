# 

# put $HOST/wrf/lib in LD_LIBRARY_PATH to use mpich libs, eg:
$ export LD_LIBRARY_PATH=$HOST/wrf/lib

# compile and link
$ make

# To test the mpich and slurm implementation:
# edit test.sh to your environment
$ sbatch test.sh
$ cat mpitest.out

# To test in local cores:
$ mpiexec -n 4 ./mpi_hello_world

# To test mpd.hosts:
$ mpiexec -machinefile $HOME/mpd.hosts ./mpi_hello_world

To get information on the run, set:
$ export MPIR_CVAR_DEBUG_SUMMARY=1

and rerun.

