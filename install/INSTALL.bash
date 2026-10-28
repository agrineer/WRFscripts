#!/usr/bin/env bash

#  INSTALL.bash
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
#  or visit https://www.gnu.org/licenses/gpl-3.0-standalone.html or
#  see http://www.gnu.org/licenses/gpl-3.0.html
#

INSTALL_COPYRIGHT="INSTALL.bash Copyright (c) 2024-2026 Scott L. Williams, released under GNU GPL V3.0"

# this install script requires bash environment given in the
# ${WRF_SCRIPTS}/install/install_wrf_variables.bash
#
# edit install_wrf_variable.bash for your environment values
# and then source the file.

echo "INSTALL: WRF build environment variable values:"
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

# WRF versions used
WRFVER=WRFV4.8.0  # release tarballs
WPSVER=WPSV4.7.0  # 
WSUFFIX=tar.gz    #

echo "INSTALL: versions to install:"
echo "         WPS : ${WPSVER}"
echo "         WRF : ${WRFVER}"
echo " "

function make_dir() {
    
    if [[ -z ${1} ]]
    then
      echo "INSTALL ERROR: environment variable ${1} needs to be set:"
      echo "               ... exiting."
      exit 1
    fi

    if [[ -z ${2} ]]
    then
      echo "INSTALL ERROR: environment variable ${2} needs to be set:"
      echo "               ... exiting."
      exit 1
    fi

    if [[ -d ${WRF_SCRIPTS}/wrf/${2} ]]
    then
	echo "INSTALL: ${WRF_SCRIPTS}/wrf/${2} already exists...leaving alone."
	return
    fi
    
    if [[ -L ${WRF_SCRIPTS}/wrf/${2} ]]
    then
	echo "INSTALL: ${WRF_SCRIPTS}/wrf/${2} link already exists...leaving alone"
	return
    fi

    if [[ ${1} == "DEFAULT" ]]
    then
	echo "INSTALL: making ${WRF_SCRIPTS}/wrf/${2}"
	mkdir ${WRF_SCRIPTS}/wrf/${2}
    else
	if [[ -d ${1} ]]
	then
	    echo "INSTALL: linking ${1} to ${WRF_SCRIPTS}/wrf/${2}"
	    ln -s ${1} ${WRF_SCRIPTS}/wrf/${2}
	else
	    echo "INSTALL: GFS directory ${INSTALL_WRF_GFS_DIR} does not exist."
	    echo "         continuing...you can fix this manually later."
	fi
    fi
}

#----------------------------------------------------------------------
make_dir ${INSTALL_WRF_GFS_DIR} gfs_0.25
make_dir ${INSTALL_WRF_OUTPUT_DIR} output

# install library packages needed for WRF
if [[ ${INSTALL_WRF_IO_TYPE} == "SERIAL_IO" ]]
then
    echo "INSTALL: installing SERIAL_IO libraries"
    source $WRF_SCRIPTS/packages/INSTALL_LIBS_SERIAL_IO.bash
    status=$?
    if [[ $status -gt 0 ]]
    then
        echo "INSTALL ERROR: could not install SERIAL_IO libs ... exiting"
        exit 1
    fi   
fi

#---------------------------------------------------------------------
# make WRF and WPS

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
if [[ $status -gt 0 ]]
then
    echo "INSTALL ERROR: could not untar ${WRFVER}.${WSUFFIX} ... exiting"
    exit 1
fi

echo "INSTALL: untar'ing ${WPSVER}.${WSUFFIX} package"
tar xvf $WRF_SCRIPTS/packages/$WPSVER.$WSUFFIX
status=$?
if [[ $status -gt 0 ]]
then
    echo "INSTALL ERROR: could not untar ${WPSVER}.${WSUFFIX} ... exiting"
    exit 1
fi

# edit WRF/Registry file to include SFCEVP variable output
echo "INSTALL: editing REGISTRY"
cd $WRF_SCRIPTS/wrf/WRF/Registry
source $WRF_SCRIPTS/install/fix_registry.bash
status=$?
if [[ $status -gt 0 ]]
then
    echo "INSTALL ERROR: could not edit REGISTRY ... exiting"
    exit 1
fi

# build WRF first
if [[ ${INSTALL_WRF_IO_TYPE} == "SERIAL_IO" ]]
then
    echo "INSTALL: installing ${WRFVER} SERIAL_IO"
    source $WRF_SCRIPTS/install/run_wrf_serial_io_install.bash
    status=$?
    if [[ $status -gt 0 ]]
    then
        echo "INSTALL ERROR: could not install ${WRFVER} SERIAL_IO ... exiting"
        exit 1
    fi
fi

# build WPS after WRF build_
source $WRF_SCRIPTS/install/run_wps_install.bash
status=$?
if [[ $status -gt 0 ]]
then
    echo "INSTALL ERROR: could not install WPS ... exiting"
    exit 1
fi   

# some sector housekeeping
cd $WRF_SCRIPTS/wrf/sectors/ANDES03/wps
cp namelist.wps.template namelist.wps

echo "INSTALL: setting namelist.wps WPS_GEOG path"
sed -i.bak 's|/home/user|'$WRF_SCRIPTS'|' ./namelist.wps && rm namelist.wps.bak
status=$?
if [[ $status -gt 0 ]]
then
    echo "INSTALL WARNING: could not install WPS_GEOG path in namelist.wps ... continuing."
fi   

# same for template; not needed but just to be complete
sed -i.bak 's|/home/user|'$WRF_SCRIPTS'|' ./namelist.wps.template && rm namelist.wps.template.bak
status=$?
if [[ $status -gt 0 ]]
then
    echo "INSTALL WARNING: could not install WPS_GEOG path in namelist.wps.template ... continuing."
fi   

cd $WRF_SCRIPTS/wrf/sectors/ANDES03/wrf
cp namelist.input.template namelist.input

if [[ ${INSTALL_WRF_WPS_GEOG_DIR} == "NONE" ]]
then
    echo "WRF ${INSTALL_WRF_IO_TYPE} INSTALLATION complete without downloading"
    echo "or linking a WPS_GEOG directory."
    echo " "
    echo "Use '${WRF_SCRIPTS}/install/install_wps_geog.bash' to download the files"
    echo "later, if needed."
    echo " "
    echo "Do not forget to populate geo files in ${WRF_SCRIPTS}/wrf/sectors/XXXXX/wps,"
    echo "after linking or downloading the WPS_GEOG".
    echo "Also set io_forms parameters in SECTOR/wrf/namelist.input.template, if needed."
    exit 0
fi

# get or link WPS_GEOG
${WRF_SCRIPTS}/install/install_wps_geog.bash
status=$?
if [[ $status -gt 0 ]]
then
    echo "INSTALL ERROR: could not link or download WPS_GEOG ... exiting"
    exit 1
fi

echo "INSTALL: WRF ${IO} INSTALLATION complete with WPS_GEOG files."

echo "INSTALL: Populating ${WRF_SCRIPTS}/wrf/sectors/ANDES03/wps with geo files."
cd ${WRF_SCRIPTS}/wrf/sectors/ANDES03/wps
./geogrid.exe
status=$?
if [[ $status -gt 0 ]]
then
    echo "INSTALL ERROR: could not populate  ... exiting"
    exit 1
fi

echo "#########################################################################"
echo ""
echo "WRFscripts installation is done, using ${WRFVER} and ${WPSVER}."
echo ""
echo "If using a desktop, make sure you have a mpd.hosts file somewhere:"
echo ""
echo "   format for mpd.hosts-> hostname:cores for example:"
echo ""
echo "   # single node, 4 cores"
echo "   localhost:4"
echo ""
echo "   or"
echo ""
echo "   # 2 nodes, 8 cores (for a network using NFS)"
echo "   curiosity:4"  
echo "   opportunity:4"
echo ""

echo "To run, set the environment variables for a desktop as below"
echo "and to suit your environment:"
echo ""
echo "export WRF_HOME=${WRF_SCRIPTS}/wrf"
echo "export WRF_MPI=MPICH"
echo "export WRF_OPENMP_NCORES=NONE"
echo "export WRF_JCL=NONE"
echo "export WRF_MPICH_HOSTS=${HOME}/mpd.hosts # see above"
echo "export FI_PROVIDER=tcp # for MAC OS/X"
echo "export LD_LIBRARY_PATH=${WRF_HOME}/lib:/usr/local/lib:/usr/lib:/lib"
echo "export PATH=${WRF_HOME}/bin:$PATH"
echo ""
echo "For SLURM: as above but use: export WRF_JCL=SLURM # no mpd.hosts needed."
echo "           Also, review .../wrf/sectors/ANDES03/wrf_mpich.slurm"
echo "           and adjust for HPC"
echo ""
echo "Typical usage:"
echo "Go to the log directory:"
echo "\$ cd ${WRF_SCRIPTS}/wrf/log"
echo ""
echo "If there is no data in the gfs directory, then for ask for yesterday\'s"
echo "GFS data with:"
echo "\$ getdata_gfs.py"
echo ""
echo "Start processing and put into background with:"
echo "\$ runwrf -b 6 -s ANDES03 -r false &"
echo ""
echo "For data already in gfs dir:"
echo "\$ runwrf -b 6 -s ANDES03 -r false -d YYYYMMDD &"
echo ""
echo "In either case:"
echo "To monitor WPS pre-processing:"
echo "\$ tail -f ANDES03.log"
echo ""
echo "To monitor WRF processing:"
echo "\$ tail -f ${WRF_SCRIPTS}/wrf/sectors/ANDES03/wrf/rsl.error.0000"
echo ""
echo "To get GFS data from the last 10 days:"
echo "\$ getdata_gfs.py YYYYMMDD # currently gets the full date"
echo "                           # plus 1/2 of next day (6 GFS files)."
echo ""
echo "To get archived GFS data one day (4 GFS files) at a time:"
echo "\$ getarch_gfs.py YYYYMMDD"
echo ""
echo "NOTE: archived files start on 2015-01-15. However, using early files"
echo "      (2015-2019) will require adjusting the"
echo "      .../wrf/sectors/ANDES03/wrf/namelist.input file."
echo ""
echo "HAPPY WRF\'ing"
echo "#########################################################################"
echo ""
