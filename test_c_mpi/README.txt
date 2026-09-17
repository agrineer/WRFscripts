# edit test.sh to your environment

To test the mpi and slurm implementation:
$ make
$ sbatch test.sh
$ cat mpitest.out

To test in local MPICH:
$ mpiexec -n 4 ./mpi_hello_world
