#!/bin/bash
#SBATCH --job-name=mpitest      ## Name of the job
#SBATCH --chdir=/home/agrineer/WRFscripts/test_mpi_slurm
#SBATCH --output=/home/agrineer/WRFscripts/test_mpi_slurm/mpitest.out
##SBATCH --time=10:00           ## Job Duration
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4
#SBATCH --partition=Ubuntu18

/bin/bash -c "source ~/.bash_profile; mpiexec /home/agrineer/WRFscripts/test_fortran_mpi/hello_world_mpi"


