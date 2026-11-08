#!/usr/bin/env bash
#SBATCH --job-name=mpitest      ## Name of the job
#SBATCH --chdir=$HOME/WRFscripts/test_fortran_mpi
#SBATCH --output=$HOME/WRFscripts/test_fortran_mpi/mpitest.out
##SBATCH --time=10:00           ## Job Duration
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4
#SBATCH --partition=Ubuntu18

mpiexec $HOME/WRFscripts/test_fortran_mpi/mpi_hello_world.exe"


