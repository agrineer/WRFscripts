#!/usr/bin/env bash

function untar() {
    
    echo "INSTALL: getting ${1} from UCAR ..."
    curl -SLO http://www2.mmm.ucar.edu/wrf/src/wps_files/${1}
    status=$?
    if [[ $status -gt 0 ]]
    then
	echo "INSTALL ERROR: could not download ${1} ... exiting"
	exit 1
    fi

    echo "INSTALL: untar'ing ${1}"
    tar xvf ${1}
    status=$?
    if [[ $status -gt 0 ]]
    then
	echo "INSTALL ERROR: could not untar geog_high_res_mandatory.tar.gz ... exiting"
	exit 1
    fi

    rm -f ${1}
}

if [[ ${INSTALL_WRF_WPS_GEOG_DIR} == "NONE" ]]
then
    echo "INSTALL: INSTALL_WRF_WPS_GEOG_DIR == NONE; nothing to do ...exiting"
    exit 0
fi

if [[ (-d ${WRF_SCRIPTS}/wrf/WPS_GEOG) || (-L ${WRF_SCRIPTS}/wrf/WPS_GEOG) ]]
then
    echo "INSTALL: ${WRF_SCRIPTS}/wrf/WPS_GEOG already exists...leaving alone."
    echo "NOTE: ${WRF_SCRIPTS}/wrf/sectors/ANDES03/wps will be populated"
    echo "      by the existing directory WPS_GEOG."
    exit 0
fi

if [[ -d ${INSTALL_WRF_WPS_GEOG_DIR} ]]
then
    # link and exit
    echo "INSTALL: linking ${INSTALL_WRF_WPS_GEOG_DIR} to ${WRF_SCRIPTS}/wrf/WPS_GEOG"
    ln -s ${INSTALL_WRF_WPS_GEOG_DIR} ${WRF_SCRIPTS}/wrf/WPS_GEOG
    exit 0
fi

if [[ !(${INSTALL_WRF_WPS_GEOG_DIR} == "DEFAULT") ]]
then
    echo "INSTALL ERROR: unknown INSTALL_WRF_WPS_GEOG option: ${INSTALL_WRF_WPS_GEOG} "
    exit 1
fi

cd ${WRF_SCRIPTS}/wrf
echo "INSTALL: downloading WPS_GEOG tar files..."
    
# get static geo files, WPS_GEOG
cd $WRF_SCRIPTS/wrf
untar geog_high_res_mandatory.tar.gz

cd $WRF_SCRIPTS/wrf/WPS_GEOG
untar topo_gmted2010_30s.tar.bz2
untar modis_landuse_20class_30s.tar.bz2

exit 0
