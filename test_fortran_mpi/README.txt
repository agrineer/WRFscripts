use:
$ mpif90 hello_world_mpi.f90 -o hello_world_mpi.exe
to compile

use:
$ mpiexec -n 4 ./hello_world_mpi.exe
to run on MPICH

To test mpd.hosts:
mpiexec -machinefile ~/mpd.hosts ./hello_world_mpi.exe

To get information on the run, set:
$ export MPIR_CVAR_DEBUG_SUMMARY=1
and rerun

use:
$ sbatch test.sh
to run on SLURM.
You must edit test.sh to your environment

