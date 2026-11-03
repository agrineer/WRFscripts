#!/usr/bin/env bash

if [[ ${INSTALL_WRF_WPS_GEOG_DIR} == "NONE" ]]
then
    echo "INSTALL: INSTALL_WRF_WPS_GEOG_DIR == NONE; nothing to do ...exiting"
    exit 0
fi

if [[ (-d ${INSTALL_WRF_SCRIPTS_DIR}/wrf/WPS_GEOG) || (-L ${INSTALL_WRF_SCRIPTS_DIR}/wrf/WPS_GEOG) ]]
then
    echo "INSTALL: ${INSTALL_WRF_SCRIPTS_DIR}/wrf/WPS_GEOG already exists...leaving alone."
    echo "NOTE: ${INSTALL_WRF_SCRIPTS_DIR}/wrf/sectors/ANDES03/wps will be populated"
    echo "      by the existing directory WPS_GEOG."
    exit 0
fi

if [[ -d ${INSTALL_WRF_WPS_GEOG_DIR} ]]
then
    # link and exit
    echo "INSTALL: linking ${INSTALL_WRF_WPS_GEOG_DIR} to ${INSTALL_WRF_SCRIPTS_DIR}/wrf/WPS_GEOG"
    ln -s ${INSTALL_WRF_WPS_GEOG_DIR} ${INSTALL_WRF_SCRIPTS_DIR}/wrf/WPS_GEOG
    exit 0
fi

if [[ !(${INSTALL_WRF_WPS_GEOG_DIR} == "DEFAULT") ]]
then
    echo "INSTALL ERROR: unknown INSTALL_WRF_WPS_GEOG option: ${INSTALL_WRF_WPS_GEOG} "
    exit 1
fi

# get the WPS_GEOG data
echo "$0: getting WPS_GEOG data."
${INSTALL_WRF_SCRIPTS_DIR}/install/get_wps_geog.bash -d ${INSTALL_WRF_SCRIPTS_DIR}/wrf
