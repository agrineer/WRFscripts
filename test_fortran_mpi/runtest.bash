#!/usr/bin/env bash

# put $HOST/wrf/lib in LD_LIBRARY_PATH to use mpich libs, eg:
export LD_LIBRARY_PATH=$HOST/wrf/lib:$LD_LIBRARY_PATH
export PATH=$HOST/wrf/bin:$PATH
export MPIR_CVAR_DEBUG_SUMMARY=1

# compile and link
echo "making"
echo "running: mpif90 mpi_hello_world.f90 -o mpi_hello_world.exe"
echo ""
mpif90 mpi_hello_world.f90 -o mpi_hello_world.exe
echo ""

echo "testing local MPICH:"
echo "running: mpiexec -n 4 ./mpi_hello_world.exe"
mpiexec -n 4 ./mpi_hello_world.exe
echo ""

echo "testing mpd.hosts:"
echo "running mpiexec -machinefile $HOME/mpd.hosts ./mpi_hello_world.exe"
echo ""
mpiexec -machinefile $HOME/mpd.hosts ./mpi_hello_world.exe

echo ""
echo "a less verbose version:"
echo ""

sleep 1

unset MPIR_CVAR_DEBUG_SUMMARY
echo "testing local MPICH:"
echo ""
mpiexec -n 4 ./mpi_hello_world.exe
echo ""

echo "testing mpd.hosts:"
echo ""
mpiexec -machinefile $HOME/mpd.hosts ./mpi_hello_world.exe

