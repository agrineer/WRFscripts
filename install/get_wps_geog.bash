#!/usr/bin/env bash

usage() {                             
    echo "$0: usage: $0 [-h] -d directory"
    echo "$0:        where directory location to put WPS_GEOG"
    exit 1
}

function get_and_untar() {
    
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

if [ $# -gt 2 ];
then
    echo "$0: too many arguments....exiting"
    usage
    exit 1
fi

# grab the parameters
while getopts "hd:" options; do
                                
    case "${options}" in
	d) DIRECTORY=${OPTARG} ;;
	h) usage
	   ;;
	:)                                    
	    echo "$0: -${OPTARG} requires an argument."
	    usage
	    ;;
	[?])
	    usage
	    ;;
	*)                                 
	    usage
	    ;;
    esac
done

shift $((OPTIND-1))

# check parameter values

if [ -z "${DIRECTORY}" ]; # empty?
then
    echo "$0: please specify a directory ... exiting."
    usage
fi

if [ -d "${DIRECTORY}" ]; # there?
then
    echo "$0: ${DIRECTORY} found."
else
    echo "$0: ${DIRECTORY} not found...making..."
    mkdir -p ${DIRECTORY}
    if [[ $status -gt 0 ]]
    then
	echo "$0 ERROR: could not make ${DIRECTORY} ... exiting"
	exit 1
    fi
fi

# ------------------------------------------------------------------------
cd ${DIRECTORY}
echo "$0: downloading WPS_GEOG tar files ..."

echo "$0: getting geog_high_res_mandatory.tar.gz ..."
get_and_untar geog_high_res_mandatory.tar.gz
echo "$0: getting geog_high_res_mandatory.tar.gz ... done."

cd WPS_GEOG
echo "$0: getting topo_gmted2010_30s.tar.bz2 ..."
get_and_untar topo_gmted2010_30s.tar.bz2
echo "$0: getting topo_gmted2010_30s.tar.bz2 ... done."

echo "$0: getting modis_landuse_20class_30s.tar.bz2 ..."
get_and_untar modis_landuse_20class_30s.tar.bz2
echo "$0: getting modis_landuse_20class_30s.tar.bz2 ... done."
echo "$0: downloading WPS_GEOG tar files ... done."
exit 0
