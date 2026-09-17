use:
$ mpif90 hello_world_mpi.f90 -o hello_world_mpi.exe
to compile

use:
$ mpiexec -n 4 ./hello_world_mpi.exe
to run on MPICH

use:
$ sbatch test.sh
to run on SLURM.
You must edit test.sh to your environment

