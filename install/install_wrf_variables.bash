#!/usr/bin/env bash

# install_wrf_variables.bash Copyright (c) 2016-2026 Scott L. Williams
# released under GNU GPL V3.0, see http://www.gnu.org/licenses/gpl-3.0.html   

# example install variable assignation for WRF INSTALL bash script
# change to your location; replace "/home/user" with your preferred location
    
export WRF_SCRIPTS=/home/user/WRFscripts # installation home

export INSTALL_WRF_NUM_CORES=4        # number of cores for compilation

export INSTALL_WRF_IO_TYPE=SERIAL_IO

# Description: file input/output type
# options are: SERIAL_IO, PNETCDF_IO, NETCDFPAR_IO, ADIOS2_IO.
#              SERIAL_IO is the only stable one for this release.
#              The others are under devlopment

export INSTALL_WRF_OUTPUT_DIR=DEFAULT

# create output directory or link or no action
# Options are:
# - DEFAULT
#   creates the empty output directory ${WRF_SCRIPTS}/wrf/output
# - filepath to existing output directory
#   and gets linked in $WRF_SCRIPTS/wrf
# - NONE
#   will not create or link a directory; user will add later

export INSTALL_WRF_GFS_DIR=DEFAULT
# create GFS directory or link or no action
# Options are:
# - DEFAULT
#   creates the gfs_0.25 directory ${WRF_SCRIPTS}/wrf/gfs_0.25
# - filepath to existing gfs_0.25 dir
#   and gets linked in $WRF_SCRIPTS/wrf
# - NONE
#   will not create or link a directory; user will add later

export INSTALL_WRF_WPS_GEOG_DIR=DEFAULT
# download earth static data or link or no action
# Options are:
# - DEFAULT
#   downloads WPS_GEOG files to $WRF_SCRIPTS/wrf/WPS_GEOG	      
# - filepath to existing WPS_GEOG directory
#   and gets linked in $WRF_SCRIPTS/wrf
# - NONE
#   will not create or link a directory; user will add later

export INSTALL_WRF_CUDA_DIR=NONE
# determines if GPU libs are used in the MPICH compile.
# this is not used in WRF, but can be used elsewhere in other projects
# Options are:
# - NONE
#   Does not use CUDA 

# - filepath to CUDA directory, eg. /usr/local/cuda
#   NOTE: does not compile with ch4:ofi.
#         compiles and runs with ch3:nemesis and ch4:ucx.
                                      
export INSTALL_WRF_MPI=MPICH
# MPI memory access mode
# Option are: MPICH, OPENMP and MPICH+OPENMP
#             use MPICH as the others are under development
                                      
export INSTALL_WRF_IO_CHANNEL=ch4:ucx
# Options are: ch3:nemesis,ch4:ofi,ch4:ucx
#              used with MPICH or MPICH+OPENMP
#              and is ignored if MPICH is not used. 

# ---------------------------------------------------------------------
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
