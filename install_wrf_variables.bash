#!/usr/bin/env /bin/bash

# example install variable asignation for WRF INSTALL bash script

export WRFscripts=/home/agrineer/WRFscripts # installation home; from tarball

export INSTALL_WRF_IO_TYPE=SERIAL_IO  # file input/output type
                                      # options are: SERIAL_IO, PNETCDF_IO,
                                      # NETCDFPAR_IO, ADIOS2_IO

export INSTALL_WRF_WPS_GEOG=NO        # download earth static data
                                      # options are: NO and YES

export INSTALL_WRF_MPI=MPICH          # MPI memory access mode
                                      # option are: MPICH, OPENMP and
                                      # MPICH+OPENMP
                                      
export INSTALL_WRF_IO_CHANNEL=ch4:ofi
                                      # options are: ch3:nemesis,ch4:ofi,ch4:ucx
                                      # used with MPICH or MPICH+OPENMP
                                      # and is ignored if not,
                                      # eg. INSTALL. OPENMP
 

export INSTALL_WRF_USE_CUDA=NONE
                                      # use GPU, options are: CUDA directory
                                      # or NONE
                                      # NOTE: does not compile with ch4:ofi.
                                      #       compiles and runs with ch3:nemesis
                                      #       without much improvement on desktop        
