
# install_wrf_variables.bash Copyright (c) 2016-2026 Scott L. Williams
# released under GNU GPL V3.0, see http://www.gnu.org/licenses/gpl-3.0.html   

# example install variable assignation for WRF INSTALL bash script
# change to your location; replace "/home/user"\
    
export WRF_SCRIPTS=/home/agrineer/WRFscripts # installation home

export INSTALL_WRF_NUM_CORES=6        # number of cores for compilation

export INSTALL_WRF_IO_TYPE=SERIAL_IO  # file input/output type
                                      # options are: SERIAL_IO, PNETCDF_IO,
                                      # NETCDFPAR_IO, ADIOS2_IO.
                                      # SERIAL_IO is the only stable one for this release

export INSTALL_WRF_WPS_GEOG=NO       # download earth static data
                                      # options are: NO and YES

export INSTALL_WRF_MPI=MPICH          # MPI memory access mode
                                      # option are: MPICH, OPENMP and
                                      # MPICH+OPENMP
                                      
export INSTALL_WRF_IO_CHANNEL=ch4:ucx
                                      # options are: ch3:nemesis,ch4:ofi,ch4:ucx
                                      # used with MPICH or MPICH+OPENMP
                                      # and is ignored if MPICH is not used. 
                                      # eg. INSTALL. OPENMP
 

export INSTALL_WRF_USE_CUDA=/usr/local/cuda
                                      # use GPU, options are: CUDA directory, 
                                      # eg. /usr/local/cuda, or NONE
                                      # NOTE: does not compile with ch4:ofi.
                                      #       compiles and runs with ch3:nemesis and ch4:ucx.
                                      #       this is not used in WRF, but can be used
                                      #       elsewhere in other projects

echo "WRF build environment variable values:"
echo "    WRF_SCRIPTS            = ${WRF_SCRIPTS}"
echo "    INSTALL_WRF_NUM_CORES  = ${INSTALL_WRF_NUM_CORES}"
echo "    INSTALL_WRF_IO_TYPE    = ${INSTALL_WRF_IO_TYPE=SERIAL_IO}"
echo "    INSTALL_WRF_WPS_GEOG   = ${INSTALL_WRF_WPS_GEOG}"
echo "    INSTALL_WRF_MPI        = ${INSTALL_WRF_MPI}"
echo "    INSTALL_WRF_IO_CHANNEL = ${INSTALL_WRF_IO_CHANNEL}"
echo "    INSTALL_WRF_USE_CUDA   = ${INSTALL_WRF_USE_CUDA}"
echo " "
echo " Now run: source INSTALL.bash 2>&1 | tee WRFscripts-build.txt"
