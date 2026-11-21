#!/usr/bin/env bash

echo "Starting WPS configure and compile"

export NETCDF=$INSTALL_WRF_SCRIPTS_DIR/wrf

cd $INSTALL_WRF_SCRIPTS_DIR/wrf/WPS
./clean -a

OPTION=1  # GNU/Linux gfortran configure option

echo "run_wps_install: using option ${OPTION} below."
./configure --build-grib2-libs << EOF
${OPTION}                
EOF

status=$?
if [[ $status -gt 0 ]]
then
    echo "run_wps_install: could not configure WPS"
    exit 1
fi

# TODO: edit configure.wps to add -lgomp for OPENMP
./compile 2>&1 | tee WPS-build.txt

status=$?
if [[ $status -gt 0 ]]
then
    echo "run_wps_install: could not compile WPS"
    exit 1
fi

echo "End of WPS install"
