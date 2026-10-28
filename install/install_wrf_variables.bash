#!/usr/bin/env bash

# install_wrf_variables.bash Copyright (c) 2016-2026 Scott L. Williams
# released under GNU GPL V3.0, see http://www.gnu.org/licenses/gpl-3.0.html   

# example install variable assignation for WRF INSTALL bash script
    
export WRF_SCRIPTS=/home/user/WRFscripts # installation home
# Sets the location of where WRFscripts.tar was extracted to or
# cloned to.  Change "/home/user/" to your choice.

export INSTALL_WRF_NUM_CORES=4        # number of cores for WRF compilation
# Sets the number of cores to use for compilation.
# A higher number has, on occasion, confused the compiler.

export INSTALL_WRF_IO_TYPE=SERIAL_IO
# Sets the file input/output type
# Options are: SERIAL_IO, PNETCDF_IO, NETCDFPAR_IO, ADIOS2_IO.
#              SERIAL_IO is the only stable one for this release.
#              The others are under devlopment

export INSTALL_WRF_OUTPUT_DIR=DEFAULT
# Determines if to create the output directory, or to the set link path,
# or to take no action.
# Options are:
#    - DEFAULT
#      Creates the output directory, ${WRF_SCRIPTS}/wrf/output.
#      In case of a rebuild (not a cloned install), and if the output
#      directory or link already exists it will be skipped (no action).
#
#    - Path to existing output directory which gets linked to
#      in ${WRF_SCRIPTS}/wrf. If the output directory or link already exists
#      it will be skipped (no action).
#
#    - NONE
#      This option ignores making or linking the output directory and
#      takes no action. The user will manually fix.
#

export INSTALL_WRF_GFS_DIR=DEFAULT
# Determines if to create the input ${WRF_SCRIPTS}/wrf/gfs_0.25 directory,
# or to set the link path, or to take no action.

# Options are:
#   - DEFAULT
#     Creates the input ${WRF_SCRIPTS}/wrf/gfs_0.25 directory,
#     $WRF_SCRIPTS/wrf/gfs_0.25. In case of a rebuild
#     (not a cloned install), and if the gfs_0.25 directory
#     or link already exists it will be skipped (no action).
#
#   - Path to existing GFS directory and gets linked to
#     in $WRF_SCRIPTS/wrf. If the directory ${WRF_SCRIPTS}/wrf/gfs_0.25
#     directory or link already exists it will be skipped (no action).
#
#   - NONE
#     Ignores making or linking the gfs_0.25 directory and
#     takes no action. The user will manually fix.

export INSTALL_WRF_WPS_GEOG_DIR=DEFAULT
# Determines if the large WPS_GEOG data directory gets downloaded from UCAR, or
# to set the link path or to take no action.
# Options are:
# - DEFAULT
#   Downloads from UCAR the WPS static data and creates
#   ${WRF_SCRIPTS}/wrf/WPS_GEOG. In case of a rebuild (not a cloned install),
#   and if the WPS_GEOG directory or link already exists it will be skipped
#   (no action).
#
# - Path to existing WPS_GEOG directory and gets linked in ${WRF_SCRIPTS}/wrf
#
# - NONE
#   Ignores making or linking the WPS_GEOG directory.The user will manually fix.

export INSTALL_WRF_MPI=MPICH
# Specifies what type of MPI to use, ie. MPI memory access mode
# Options are:
#   - MPICH (use this option as the others are currently under
#     development)
#     Used for communication between nodes and node cores.
#	     
#   - OPENMP
#     Used for comunication between a node's cores.
#	     
#   - MPICH+OPENMP
#     Used to specify a hybrid comunication.
#
#   MPICH+OPENMP and OPENMP implementation is still being developed
#   and should not be used currently.

export INSTALL_WRF_IO_CHANNEL=ch4:ucx
# Determines IO channels (communication transport) to use
# Options are:
#  - ch3:nemesis (legacy)
#  - ch4:ofi (does not work with CUDA)
#  - ch4:ucx (default)

export INSTALL_WRF_CUDA_DIR=NONE
# Determines if GPU libs are used in the MPICH compile.
# CUDA is not used in WRF, but can be used elsewhere in other projects
# Options are:
# - NONE
#   Does not use CUDA libraries 

# - Path to CUDA directory, eg. /usr/local/cuda
#   NOTE: Does not compile with ch4:ofi.
#         Compiles and runs with ch3:nemesis and ch4:ucx.
#   NOTE: CUDA implementation does not work with MAC OS/X.
                                     
                                      
#-------------------------------------------------------------------
# Preliminary checks of INSTALL environment bash variables

# check if environment variable directory has been set
function check_dir() {

    if [[ -z $1 ]]
    then
      echo "INSTALL ERROR: environment variable ${1} needs to be set:"
      echo "               ... exiting"
      exit 1
    fi

    if [[ (${1} == "NONE") || (${1} == "DEFAULT") ]]
    then
	return
    fi

    # check if directory exists
    if [[ ! -d $1 ]]; then
	echo "INSTALL ERROR: file ${1} not found!"
	echo "               ... exiting"
	exit 1
    fi
}

# check directories
check_dir $WRF_SCRIPTS
check_dir $INSTALL_WRF_OUTPUT_DIR
check_dir $INSTALL_WRF_GFS_DIR
check_dir $INSTALL_WRF_WPS_GEOG_DIR
check_dir $INSTALL_WRF_CUDA_DIR

#-------------------------------------------------
# error check IO_TYPE
if [[ -z ${INSTALL_WRF_IO_TYPE} ]]
then
    echo "INSTALL ERROR: INSTALL_WRF_IO_TYPE environment variable needs to be set:"
    echo "               eg. export INSTALL_WRF_IO_TYPE=SERIAL_IO"
    exit 1
fi

if   ! [[ ${INSTALL_WRF_IO_TYPE} == "SERIAL_IO" ]] 
then
    echo "INSTALL ERROR: given INSTALL_WRF_IO_TYPE value: ${INSTALL_WRF_IO_TYPE} is not recognized"
    echo "see example install_wrf_variables.bash...exiting"
    exit 1
fi

# error check NUM_CORES
if [[ ! $INSTALL_WRF_NUM_CORES =~ ^[0-9]+$ ]]
then
    echo "INSTALL_ERROR: ${INSTALL_WRF_NUM_CORES} is not a positive integer."
    echo "               ... exiting"
    exit 1
fi

# error check WRF_MPI
if [[ -z ${INSTALL_WRF_MPI} ]]
then
    echo "INSTALL ERROR: INSTALL_WRF_MPI environment variable needs to be set:"
    echo "eg. export INSTALL_WRF_MPI=MPICH"
    echo "see example install_wrf_variables.bash...exiting"
    exit 1
fi

if   ! [[ ${INSTALL_WRF_MPI} == "MPICH" ]]        \
  && ! [[ ${INSTALL_WRF_MPI} == "OPENMP" ]]       \
  && ! [[ ${INSTALL_WRF_MPI} == "MPICH+OPENMP" ]] 
then
    echo "INSTALL ERROR: given INSTALL_WRF_MPI value: ${INSTALL_WRF_MPI} is not recognized"
    echo "               eg. export INSTALL_WRF_MPI=MPICH"
    exit 1
fi

# error check for transport channel if WRF_MPI includes MPICH
if     [[ ${INSTALL_WRF_MPI} == "MPICH" ]]        \
    || [[ ${INSTALL_WRF_MPI} == "MPICH+OPENMP" ]]
then
    # transport channel
    if [[ -z ${INSTALL_WRF_IO_CHANNEL} ]]
    then
        echo "INSTALL ERROR: INSTALL_WRF_IO_CHANNEL environment variable needs to be set:"
	echo "               eg. export INSTALL_WRF_IO_CHANNEL=ch4:ofi"
        exit 1
    fi

    # TODO: get colon arg for ch3
    if   ! [[ ${INSTALL_WRF_IO_CHANNEL} == "ch3:nemesis" ]]     \
      && ! [[ ${INSTALL_WRF_IO_CHANNEL} == "ch4:ofi" ]]         \
      && ! [[ ${INSTALL_WRF_IO_CHANNEL} == "ch4:ucx" ]]
    then
        echo "INSTALL error: given INSTALL_WRF_IO_CHANNEL value: ${INSTALL_WRF_IO_CHANNEL} is not recognized"
        echo "               eg. export INSTALL_WRF_CHANNEL=ch4:ofi"
        exit 1
    fi
fi


echo "WRF build environment variable values:"
echo "                  WRF_SCRIPTS = ${WRF_SCRIPTS}"
echo "        INSTALL_WRF_NUM_CORES = ${INSTALL_WRF_NUM_CORES}"
echo "          INSTALL_WRF_IO_TYPE = ${INSTALL_WRF_IO_TYPE=SERIAL_IO}"
echo "       INSTALL_WRF_OUTPUT_DIR = ${INSTALL_WRF_OUTPUT_DIR}"
echo "          INSTALL_WRF_GFS_DIR = ${INSTALL_WRF_GFS_DIR}"
echo "     INSTALL_WRF_WPS_GEOG_DIR = ${INSTALL_WRF_WPS_GEOG_DIR}"
echo "         INSTALL_WRF_CUDA_DIR = ${INSTALL_WRF_CUDA_DIR}"
echo "              INSTALL_WRF_MPI = ${INSTALL_WRF_MPI}"
echo "       INSTALL_WRF_IO_CHANNEL = ${INSTALL_WRF_IO_CHANNEL}"
echo " "
echo " Now run: ./INSTALL.bash 2>&1 | tee WRFscripts-build.txt"
