#!/bin/bash

#  INSTALL_LIBS_NETCDFPAR_IO
# 
#  Copyright (c) 2024-2025 Scott L. Williams
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

# UNDER CONSTRUCTION !!!
INSTALL_LIBS_NETCDFPAR_IO_copyright="INSTALL_LIBS_NETCDFPAR_IO Copyright (c) 2020-2025 Scott L. Williams ' + 'released under GNU GPL V3.0"

untar_package()
{
    echo "untar'ing ${PNAME}.${SUFFIX}"
    tar xvf $PNAME.$SUFFIX
    status=$?
    if [ $status -gt 0 ]
    then
	echo "INSTALL_LIBS_PNETCDF_IO: could not untar ${PNAME}.${SUFFIX}"
	exit 1
    fi
}

# test and report configure
check_configure()
{
    if [ ${PIPESTATUS[0]} -gt 0 ]
    then
	echo "INSTALL_LIBS_PNETCDF_IO: could not configure ${PNAME}"
	echo "review ${WRFscripts}/wrf/packages/${PNAME}/${PNAME}_config.log"
	echo "and ${WRFscripts}/wrf/packages/${PNAME}/config.log for details"
	exit 1
    fi
}

# test and report make
check_make()
{
    if [ ${PIPESTATUS[0]} -gt 0 ]
    then
	echo "INSTALL_LIBS_PNETCDF_IO: could not make ${PNAME}"
	echo "review ${WRFscripts}/wrf/packages/${PNAME}/${PNAME}_make.log for details"
	exit 1
    fi
}

# test and report make install
check_make_install()
{
    if [ ${PIPESTATUS[0]} -gt 0 ]
    then
	echo "INSTALL_LIBS_PNETCDF_IO: could not make install ${PNAME}"
	echo "review ${WRFscripts}/wrf/packages/${PNAME}/${PNAME}_make_install.log for details"
	exit 1
    fi
}

print_env()
{
    echo ""
    echo "installing ${PNAME} with these variable values:"
    if [ "$CC" != "" ]
    then
	echo "CC=${CC}"
    fi

    if [ "$MPICC" != "" ]
    then
	echo "MPICC=${MPICC}"
    fi

    if [ "$CFLAGS" != "" ]
    then
	echo "CFLAGS=${CFLAGS}"
    fi

    if [ "$CPPFLAGS" != "" ]
    then
	echo "CPPFLAGS=${CPPFLAGS}"
    fi

    if [ "$FC" != "" ]
    then
	echo "FC=${FC}"
    fi

    if [ "$FCFLAGS" != "" ]
    then
	echo "FCFLAGS=${FCFLAGS}"
    fi

    if [ "$MPIF90" != "" ]
    then
	echo "MPIF90=${MPIF90}"
    fi

    if [ "$LD_LIBRARY_PATH" != "" ]
    then
	echo "LD_LIBRARY_PATH=${LD_LIBRARY_PATH}"
    fi
    
    if [ "$LDFLAGS" != "" ]
    then
	echo "LDFLAGS=${LDFLAGS}"
    fi

    if [ "$FFLAGS" != "" ]
    then
	echo "CPPFLAGS=${CPPFLAGS}"
    fi

    echo "CONF_PARAMS=${CONF_PARAMS}"  # must always have CONF_PARAMS
    echo ""
}

make_lib()
{
    print_env
    
    cd $WRFscripts/packages
    rm -rf $PNAME

    untar_package # parameters are PNAME and SUFFIX
    cd $PNAME
   
    echo "configuring ${PNAME} on ${HOSTNAME}"

    ./configure $CONF_PARAMS 2>&1 | tee ${PNAME}_config.log
    check_configure

    echo "making ${PNAME}"
    make -j 4 2>&1 | tee ${PNAME}_make.log
    check_make
    
    echo "make install ${PNAME}"
    make install 2>&1 | tee ${PNAME}_make_install.log
    check_make_install

    echo "installing ${PNAME} done"
}

# clear all environment variables used in this script
clear_vars()
{
    unset PNAME
    unset SUFFIX
    unset CC
    unset MPICC
    unset CPPFLAGS
    unset FC
    unset FCFLAGS
    unset MPIF90
    unset LD_LIBRARY_PATH
    unset LDFLAGS
    unset CONF_PARAMS
    unset FFLAGS
}

#----------------------------------------------------------------------
# main

# INSTALL WRF dependent libraries
echo ""
echo "Installing NETCDFPAR I/O WRF dependent libraries"

cd $WRFscripts/wrf

echo "cleaning ${WRFscripts}/wrf/include"
rm -rf include
mkdir include

echo "cleaning ${WRFscripts}/wrf/lib"
rm -rf lib
mkdir lib

echo "cleaning ${WRFscripts}/wrf/bin"
rm -rf bin
mkdir bin
cd bin
ln -s ../scripts/getdata_gfs.py
ln -s ../scripts/runwrf

# source URL for mpich
# https://www.mpich.org/downloads/

# install MPICH first so that HDF5 configures as parallel
clear_vars
PNAME=mpich-4.2.1         # package name
SUFFIX=tar.gz
DEVICE="--with-device=${INSTALL_WRF_IO_CHANNEL}"
if [ ${INSTALL_WRF_USE_CUDA} = "YES" ]
    then
	CUDA="--with-cuda=/usr/local/cuda"
	echo "INSTALL_LIBS_NETCDFPAR_IO: compiling MPICH with CUDA"
    else
	CUDA="--without-cuda"
	echo "INSTALL_LIBS_NETCDFPAR_IO: compiling MPICH without CUDA"
    fi

CONF_PARAMS="--prefix=${WRFscripts}/wrf ${CUDA} ${DEVICE}"
make_lib

# you can download HDF5 from the HDF5 download page.
# Go to https://www.hdfgroup.org/downloads/hdf5
# Scroll down and click on "Specific release?"    
# download and put into the tarball into wrf/packages
clear_vars
PNAME=hdf5-1.10.10
SUFFIX=tar.bz2
CONF_PARAMS="--prefix=${WRFscripts}/wrf --enable-fortran --enable-parallel"
export CC=mpicc
export FC=mpif90
make_lib

# wget https://downloads.unidata.ucar.edu/netcdf-c/4.9.2/netcdf-c-4.9.2.tar.gz
clear_vars
PNAME=netcdf-c-4.9.2
SUFFIX=tar.gz
#CONF_PARAMS="--prefix=${WRFscripts}/wrf --disable-dap --disable-libxml2 --disable-byterange --enable-netcdf4 --enable-parallel-tests --enable-largefile"
CONF_PARAMS="--prefix=${WRFscripts}/wrf --disable-dap --disable-libxml2 --disable-byterange --enable-netcdf4 --enable-parallel-tests"
export CC=mpicc
export CPPFLAGS=-I$WRFscripts/wrf/include
export LDFLAGS=-L$WRFscripts/wrf/lib
make_lib

# wget https://downloads.unidata.ucar.edu/netcdf-fortran/4.6.1/netcdf-fortran-4.6.1.tar.gz
clear_vars
PNAME=netcdf-fortran-4.5.4
SUFFIX=tar.gz
#CONF_PARAMS="--prefix=${WRFscripts}/wrf --enable-parallel-tests --enable-largefile"
CONF_PARAMS="--prefix=${WRFscripts}/wrf --enable-parallel-tests"
export CC=mpicc
export CPPFLAGS=-I$WRFscripts/wrf/include
export FC=mpif90
export LDFLAGS=-L$WRFscripts/wrf/lib
make_lib

echo "Installing NETCDFPAR I/O WRF dependent libraries done"
