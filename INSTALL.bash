#!/usr/bin/env /bin/bash

#  INSTALL.bash WRF with environment variables parameters 
# 
#  Copyright (c) 2024-2026 Scott L. Williams
# 
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 3 of the License, or
#  (at your option) any later version.
# 
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
# 
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#  or visit https://www.gnu.org/licenses/gpl-3.0-standalone.html
#

INSTALL_COPYRIGHT="INSTALL.bash Copyright (c) 2024-2026 Scott L. Williams ' + 'released under GNU GPL V3.0"

# this install script requires bash environment given in the
# example install_wrf_variables.bash
#
# edit install_wrf_variable.bash for your environment values
# and then source the file

# WRF versions used
WRFVER=WRFV4.8.0  # release tarballs
WPSVER=WPSV4.7.0  # 
WSUFFIX=tar.gz    #

# check INSTALL environment bash variables

# check if WRF_SCRIPTS enviroment variable has been set
if [ -z "${WRF_SCRIPTS}" ]
then
    echo "INSTALL ERROR: WRF_SCRIPTS environment variable needs to be set:"
    echo "eg. export WRF_SCRIPTS=/home/user/WRF_SCRIPTS ... exiting"
    exit 1
fi

# check if WRF_SCRIPTS directory exists
if [ ! -d ${WRF_SCRIPTS} ]; then
    echo "INSTALL ERROR: file ${WRF_SCRIPTS} not found!"
    echo "INSTALL ERROR: exiting"
    exit 1
fi
# error check IO_TYPE
if [ -z "${INSTALL_WRF_IO_TYPE}" ]
then
    echo "INSTALL ERROR: INSTALL_WRF_IO_TYPE environment variable needs to be set:"
    echo "eg. export INSTALL_WRF_IO_TYPE=PNETCDF"
    echo "see example install_wrf_variables.bash ... exiting"
    exit 1
fi

if   ! [ ${INSTALL_WRF_IO_TYPE} = "SERIAL_IO" ]    \
  && ! [ ${INSTALL_WRF_IO_TYPE} = "PNETCDF_IO" ]   \
  && ! [ ${INSTALL_WRF_IO_TYPE} = "NETCDFPAR_IO" ] \
  && ! [ ${INSTALL_WRF_IO_TYPE} = "ADIOS2_IO" ]
then
    echo "INSTALL ERROR: given INSTALL_WRF_IO_TYPE value: ${INSTALL_WRF_IO_TYPE} is not recognized"
    echo "see example install_wrf_variables.bash...exiting"
    exit 1
fi

# error check for WPS_GEOG flag
if [ -z "${INSTALL_WRF_WPS_GEOG}" ]
then
    echo "INSTALL ERROR: INSTALL_WRF_WPS_GEOG environment variable needs to be set:"
    echo "eg. export INSTALL_WRF_WPS_GEOG=NO"
    echo "see example install_wrf_variables.bash...exiting"
    exit 1
fi

if   ! [ ${INSTALL_WRF_WPS_GEOG} = "NO" ] \
  && ! [ ${INSTALL_WRF_WPS_GEOG} = "YES" ]
then 
    echo "INSTALL ERROR: given WPS_GEOG value: ${INSTALL_WRF_WPS_GEOG} is not recognized"
    echo "should be YES or NO"
    echo "see example install_wrf_variables.bash...exiting"
    exit 1
fi

# error check WRF_MPI
if [ -z "${INSTALL_WRF_MPI}" ]
then
    echo "INSTALL ERROR: INSTALL_WRF_MPI environment variable needs to be set:"
    echo "eg. export INSTALL_WRF_MPI=MPICH"
    echo "see example install_wrf_variables.bash...exiting"
    exit 1
fi

if   ! [ ${INSTALL_WRF_MPI} = "MPICH" ]        \
  && ! [ ${INSTALL_WRF_MPI} = "OPENMP" ]       \
  && ! [ ${INSTALL_WRF_MPI} = "MPICH+OPENMP" ] 
then
    echo "INSTALL ERROR: given INSTALL_WRF_MPI value: ${INSTALL_WRF_MPI} is not recognized"
    echo "eg. export INSTALL_WRF_MPI=MPICH"
    echo "see example install_wrf_variables.bash...exiting"
    exit 1
fi

# error check for transport channel if WRF_MPI includes MPICH
if     [ ${INSTALL_WRF_MPI} = "MPICH" ]        \
    || [ ${INSTALL_WRF_MPI} = "MPICH+OPENMP" ]
then
    # transport channel
    if [ -z "${INSTALL_WRF_IO_CHANNEL}" ]
    then
	echo "INSTALL ERROR: INSTALL_WRF_IO_CHANNEL environment variable needs to be set:"
	echo "eg. export INSTALL_WRF_IO_CHANNEL=ch4:ofi"
	echo "see example install_wrf_variables.bash...exiting"
	exit 1
    fi

    # TODO: get colon arg for ch3
    if   ! [ ${INSTALL_WRF_IO_CHANNEL} = "ch3:nemesis" ]     \
      && ! [ ${INSTALL_WRF_IO_CHANNEL} = "ch4:ofi" ]         \
      && ! [ ${INSTALL_WRF_IO_CHANNEL} = "ch4:ucx" ]
    then
	echo "INSTALL error: given INSTALL_WRF_IO_CHANNEL value: ${INSTALL_WRF_IO_CHANNEL} is not recognized"
	echo "eg. export INSTALL_WRF_CHANNEL=ch4:ofi"
	echo "see example install_wrf_variables.bash...exiting"
	exit 1
    fi
fi

echo "WRF build environment variable values:" 
echo "    WRF_SCRIPTS directory   : ${WRF_SCRIPTS}" 
echo "    NUM_CORES (Compile)     : ${NUM_CORES}" 
echo "    INSTALL_WRF_IO_TYPE     : ${INSTALL_WRF_IO_TYPE}" 
echo "    INSTALL_WRF_WPS_GEOG    : ${INSTALL_WRF_WPS_GEOG}" 
echo "    INSTALL_WRF_MPI         : ${INSTALL_WRF_MPI}"
echo "    INSTALL_WRF_IO_CHANNEL  : ${INSTALL_WRF_IO_CHANNEL}" 
echo "    INSTALL_WRF_USE_CUDA    : ${INSTALL_WRF_USE_CUDA}" 
echo ""

#----------------------------------------------------------------------

# install library packages needed for WRF
if [ ${INSTALL_WRF_IO_TYPE} = "SERIAL_IO" ]
then
    #echo "INSTALL: installing SERIAL_IO libraries"
    $WRF_SCRIPTS/packages/INSTALL_LIBS_SERIAL_IO
    status=$?
    if [ $status -gt 0 ]
    then
	echo "INSTALL ERROR: could not install SERIAL_IO libs ... exiting"
	exit 1
    fi   
fi

if [  ${INSTALL_WRF_IO_TYPE} = "PNETCDF_IO" ]
then
    #echo "INSTALL: installing PNETCDF_IO libraries"
    $WRF_SCRIPTS/packages/INSTALL_LIBS_PNETCDF_IO
    status=$?
    if [ $status -gt 0 ]
    then
	echo "INSTALL ERROR: could not install PNETCDF_IO libs ... exiting"
	exit 1
    fi   
fi

if [ ${INSTALL_WRF_IO_TYPE} = "NETCDFPAR_IO" ]
then
    #echo "INSTALL: installing NETCDFPAR_IO libraries"
    $WRF_SCRIPTS/packages/INSTALL_LIBS_NETCDFPAR_IO
    status=$?
    if [ $status -gt 0 ]
    then
	echo "INSTALL ERROR: could not install NETCDFPAR_IO libs ... exiting"
	exit 1
    fi   
fi

if [ ${INSTALL_WRF_IO_TYPE} = "ADIOS2_IO" ]
then
    #echo "INSTALL: installing ADIOS2_IO libraries"
    $WRF_SCRIPTS/packages/INSTALL_LIBS_ADIOS2_IO
    status=$?
    if [ $status -gt 0 ]case 
    then
	echo "INSTALL ERROR: could not install ADIOS2_IO libs ... exiting"
	exit 1
    fi   
fi

# make WPS and WRF

# add WRF_SCRIPTS locations to paths (set these after LIB installs)
export PATH=$WRF_SCRIPTS/wrf/bin:$PATH
export LD_LIBRARY_PATH=$WRF_SCRIPTS/wrf/lib:$LD_LIBRARY_PATH

# remove old versions if there
cd $WRF_SCRIPTS/wrf
rm -rf WRF WPS

# get WRF and WPS latest versions (not implemented)
#git clone https://github.com/wrf-model/WRF
#git clone https://github.com/wrf-model/WPS

# rejoin split WRF tar ball
echo "Rejoining ${WRFVER}.tar.gz"
cat $WRF_SCRIPTS/packages/$WRFVER\_part_* > $WRF_SCRIPTS/packages/$WRFVER.tar.gz

echo "INSTALL: untar'ing ${WRFVER}.${WSUFFIX} package"
tar xvfz $WRF_SCRIPTS/packages/$WRFVER.$WSUFFIX
status=$?
if [ $status -gt 0 ]
then
    echo "INSTALL ERROR: could not untar ${WRFVER}.${WSUFFIX} ... exiting"
    exit 1
fi

echo "INSTALL: untar'ing ${WPSVER}.${WSUFFIX} package"
tar xvf $WRF_SCRIPTS/packages/$WPSVER.$WSUFFIX
status=$?
if [ $status -gt 0 ]
then
    echo "INSTALL ERROR: could not untar ${WPSVER}.${WSUFFIX} ... exiting"
    exit 1
fi

# edit WRF/Registry file to include SFCEVP variable output
echo "INSTALL: editing REGISTRY"
cd $WRF_SCRIPTS/wrf/WRF/Registry
$WRF_SCRIPTS/fix_registry
status=$?
if [ $status -gt 0 ]
then
    echo "INSTALL ERROR: could not edit REGISTRY ... exiting"
    exit 1
fi

# build WRF first
if [ ${INSTALL_WRF_IO_TYPE} = "SERIAL_IO" ]
then
    echo "INSTALL: installing ${WRFVER} SERIAL_IO"
    $WRF_SCRIPTS/run_wrf_serial_io_install
    status=$?
    if [ $status -gt 0 ]
    then
	echo "INSTALL ERROR: could not install ${WRFVER} SERIAL_IO ... exiting"
	exit 1
    fi
fi

if [ ${INSTALL_WRF_IO_TYPE} = "PNETCDF_IO" ]
then
    echo "INSTALL: installing ${WRFVER} PNETCDF_IO"
    $WRF_SCRIPTS/run_wrf_pnetcdf_io_install
    status=$?
    if [ $status -gt 0 ]
    then
	echo "INSTALL ERROR: could not install ${WRFVER} PNETCDF_IO ... exiting"
	exit 1
    fi
fi

if [ ${INSTALL_WRF_IO_TYPE} = "NETCDFPAR_IO" ]
then
    echo "INSTALL: installing ${WRFVER} NETCDFPAR_IO"
    $WRF_SCRIPTS/run_wrf_netcdfpar_io_install
    status=$?
    if [ $status -gt 0 ]
    then
	echo "INSTALL ERROR: could not install ${WRFVER} NETCDFPAR_IO ... exiting"
	exit 1
    fi
fi

if [ ${INSTALL_WRF_IO_TYPE} = "ADIOS2_IO" ]
then
    echo "INSTALL: installing ${WRFVER} ADIOS2_IO"
    $WRF_SCRIPTS/run_wrf_adios2_io_install
    status=$?
    if [ $status -gt 0 ]
    then
	echo "INSTALL ERROR: could not install ${WRFVER} ADIOS2_IO ... exiting"
	exit 1
    fi   
fi

# build WPS after WRF build_
$WRF_SCRIPTS/run_wps_install
status=$?
if [ $status -gt 0 ]
then
    echo "INSTALL ERROR: could not install WPS ... exiting"
    exit 1
fi   

# some sector housekeeping
cd $WRF_SCRIPTS/wrf/sectors/ANDES03/wps
cp namelist.wps.template namelist.wps

cd $WRF_SCRIPTS/wrf/sectors/ANDES03/wrf
cp namelist.input.template namelist.input

if [ ${INSTALL_WRF_WPS_GEOG} = "NO" ]
then
    echo "WRF ${INSTALL_WRF_IO_TYPE} INSTALLATION complete with NO WPS_GEOG files."
    echo "Be sure to link your WPS_GEOG to $WRF_SCRIPTS/wrf/WPS_GEOG."
    echo "You must populate geo files in wrf/sectors/XXXXX/wps, set io_forms"
    echo "parameters in SECTOR/wrf/namelist.input.template, link to GFS input" 
    echo "directory if available, etc.  See README.txt"
    exit 0
fi

# get static geo files, WPS_GEOG
cd $WRF_SCRIPTS/wrf
echo "INSTALL: getting geog_high_res_mandatory.tar.gz from UCAR"
curl -SLO http://www2.mmm.ucar.edu/wrf/src/wps_files/geog_high_res_mandatory.tar.gz
status=$?
if [ $status -gt 0 ]
then
    echo "INSTALL ERROR: could not download geog_high_res_mandatory.tar.gz ... exiting"
    exit 1
fi

echo "INSTALL: untar'ing geog_high_res_mandatory.tar.gz"
tar xvf geog_high_res_mandatory.tar.gz
status=$?
if [ $status -gt 0 ]
then
    echo "INSTALL ERROR: could not untar geog_high_res_mandatory.tar.gz ... exiting"
    exit 1
fi

rm geog_high_res_mandatory.tar.gz

# add some more geo files
cd $WRF_SCRIPTS/wrf/WPS_GEOG
echo "INSTALL: getting topo_gmted2010_30s.tar.bz2 from UCAR"
curl -SLO http://www2.mmm.ucar.edu/wrf/src/wps_files/topo_gmted2010_30s.tar.bz2
status=$?
if [ $status -gt 0 ]
then
    echo "INSTALL ERROR: could not download topo_gmted2010_30s.tar.bz2 ... exiting"
    exit 1
fi

echo "INSTALL: untar'ing topo_gmted2010_30s.tar.bz2"
tar xvf topo_gmted2010_30s.tar.bz2
status=$?
if [ $status -gt 0 ]
then
    echo "INSTALL ERROR: could not untar topo_gmted2010_30s.tar.bz2 ... exiting"
    exit 1
fi
rm topo_gmted2010_30s.tar.bz2

echo "INSTALL: getting modis_landuse_20class_30s.tar.bz2 from UCAR"
curl -SLO http://www2.mmm.ucar.edu/wrf/src/wps_files/modis_landuse_20class_30s.tar.bz2
status=$?
if [ $status -gt 0 ]
then
    echo "INSTALL ERROR: could not download modis_landuse_20class_30s.tar.bz2 ... exiting"
    exit 1
fi

echo "INSTALL: untar'ing modis_landuse_20class_30s.tar.bz2"
tar xvf modis_landuse_20class_30s.tar.bz2
status=$?
if [ $status -gt 0 ]
then
    echo "INSTALL ERROR: could not untar modis_landuse_20class_30s.tar.bz2 ... exiting"
    exit 1
fi
rm modis_landuse_20class_30s.tar.bz2

echo "WRF ${IO} INSTALLATION complete with WPS_GEOG files."
echo "You must populate geo files in wrf/sectors/XXXXX/wps, "
echo "and set io_forms in $WRF_SCRIPTS/wrf/sectors/XXXXX/wrf/namelist.input.org"
echo "See README.txt"
