#!/usr/bin/env bash

# put $HOST/wrf/lib in LD_LIBRARY_PATH to use mpich libs, eg:
export LD_LIBRARY_PATH=$HOST/wrf/lib:$LD_LIBRARY_PATH
export PATH=$HOST/wrf/bin:$PATH
export MPIR_CVAR_DEBUG_SUMMARY=1

# compile and link
echo "making"
echo "running: make"
make
echo ""

echo "testing local MPICH:"
echo "running: mpiexec -n 4 ./mpi_hello_world"
mpiexec -n 4 ./mpi_hello_world
echo ""

echo "testing mpd.hosts:"
echo "runnung: mpiexec -machinefile $HOME/mpd.hosts ./mpi_hello_world"
mpiexec -machinefile $HOME/mpd.hosts ./mpi_hello_world
echo ""

echo "a less verbose version:"
echo ""

sleep 1

unset MPIR_CVAR_DEBUG_SUMMARY
echo "testing local MPICH:"
echo ""
mpiexec -n 4 ./mpi_hello_world
echo ""

echo "testing mpd.hosts:"
echo ""
mpiexec -machinefile $HOME/mpd.hosts ./mpi_hello_world
