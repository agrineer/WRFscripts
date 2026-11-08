
# put $HOST/wrf/lib in LD_LIBRARY_PATH to use mpich libs, eg:
$ export LD_LIBRARY_PATH=$HOST/wrf/lib
$ export $PATH=$HOST/wrf/bin

# To compile and link use:
$ mpif90 mpi_hello_world.f90 -o mpi_hello_world.exe

# To run on SLURM, edit test.sh to suit your environment then:
$ sbatch test.sh

# To test local cores:
$ mpiexec -n 4 ./mpi_hello_world.exe

# To test mpd.hosts:
mpiexec -machinefile ~/mpd.hosts ./mpi_hello_world.exe

To get information on the run, set:
$ export MPIR_CVAR_DEBUG_SUMMARY=1

and rerun.

