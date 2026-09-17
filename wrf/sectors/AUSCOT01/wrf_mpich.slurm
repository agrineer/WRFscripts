#!/bin/bash
##
##
#SBATCH --job-name=AUSCOT01
#SBATCH --chdir=/home/agrineer/wrf/sectors/AUSCOT01/wrf
#SBATCH --output=/home/agrineer/wrf/log/AUSCOT01_slurm.log
##SBATCH --time=100:00:00
#SBATCH --partition=Ubuntu18
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=4

# /bin/bash -c "source /home/user/.bash_profile; mpiexec /home/user/agrineerWRF/wrf/sectors/AUSCOT01/wrf/wrf.exe"

mpiexec /home/agrineer/wrf/sectors/AUSCOT01/wrf/wrf.exe
