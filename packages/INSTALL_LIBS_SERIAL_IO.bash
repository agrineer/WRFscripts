#  INSTALL_LIBS_SERIAL_IO
# 
#  Copyright (c) 2020-2026 Scott L. Williams
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

INSTALL_LIBS_SERIAL_IO_copyright="INSTALL_LIBS_SERIAL_IO Copyright (c) 2020-2026 Scott L. Williams ' + 'released under GNU GPL V3.0"

untar_package()
{
    echo "INSTALL_LIBS_SERIAL_IO: untar'ing ${PNAME}.${SUFFIX}"
    tar xvf $PNAME.$SUFFIX
    status=$?
    if [[ $status -gt 0 ]]
    then
        echo "INSTALL_LIBS_SERIAL_IO: could not untar ${PNAME}.${SUFFIX}"
        exit 1
    fi
}

# test and report configure
check_configure()
{
    if [[ ${PIPESTATUS[0]} -gt 0 ]]
    then
        echo "INSTALL_LIBS_SERIAL_IO: could not configure ${PNAME}"
        echo "review ${WRF_SCRIPTS}/wrf/packages/${PNAME}/${PNAME}_config.log"
        echo "and ${WRF_SCRIPTS}/wrf/packages/${PNAME}/config.log for details"
        exit 1
    fi
}

# test and report make
check_make()
{
    if [[ ${PIPESTATUS[0]} -gt 0 ]]
    then
        echo "INSTALL_LIBS_SERIAL_IO: could not make ${PNAME}"
        echo "review ${WRF_SCRIPTS}/wrf/packages/${PNAME}/${PNAME}_make.log for details"
        exit 1
    fi
}

# test and report make install
check_make_install()
{
    if [[ ${PIPESTATUS[0]} -gt 0 ]]
    then
        echo "INSTALL_LIBS_SERIAL_IO: could not make install ${PNAME}"
        echo "review ${WRF_SCRIPTS}/wrf/packages/${PNAME}/${PNAME}_make_install.log for details"
        exit 1
    fi
}

print_env()
{
    echo ""
    echo "INSTALL_LIBS_SERIAL_IO: installing ${PNAME} with these variable values and flags:"

    # print variable if populated
    
    if [[ -n "${CC}" ]]
    then
        echo "CC=${CC}"
    fi

    if [[ -n "${MPICC}" ]]
    then
        echo "MPICC=${MPICC}"
    fi

    if [[ -n "${CFLAGS}" ]]
    then
        echo "CFLAGS=${CFLAGS}"
    fi

    if [[ -n "${CPPFLAGS}" ]]
    then
        echo "CPPFLAGS=${CPPFLAGS}"
    fi

    if [[ -n "${CXXFLAGS}" ]]
    then
        echo "CXXFLAGS=${CXXFLAGS}"
    fi

    if [[ -n "${FC}" ]]
    then
        echo "FC=${FC}"
    fi

    if [[ -n "${FCFLAGS}" ]]
    then
        echo "FCFLAGS=${FCFLAGS}"
    fi

    if [[ -n "${MPIF90}" ]]
    then
        echo "MPIF90=${MPIF90}"
    fi

    if [[ -n "${LD_LIBRARY_PATH}" ]]
    then
        echo "LD_LIBRARY_PATH=${LD_LIBRARY_PATH}"
    fi
    
    if [[ -n "${LDFLAGS}" ]]
    then
        echo "LDFLAGS=${LDFLAGS}"
    fi

    if [[ -n "${FFLAGS}" ]]
    then
        echo "FFLAGS=${FFLAGS}"
    fi

    echo "CONF_PARAMS=${CONF_PARAMS}"  # must always have CONF_PARAMS
    echo ""
}

make_lib()
{
    print_env
    
    cd $WRF_SCRIPTS/packages
    rm -rf $PNAME # remove old package dir

    untar_package # parameters are PNAME and SUFFIX
    cd $PNAME
   
    echo "configuring ${PNAME} on ${HOSTNAME}"

    ./configure $CONF_PARAMS 2>&1 | tee $PNAME\_config.log
    check_configure

    echo "making ${PNAME}"
    make -j $INSTALL_WRF_NUM_CORES 2>&1 | tee $PNAME\_make.log
    check_make
    
    echo "make install ${PNAME}"
    make install 2>&1 | tee $PNAME\_make_install.log
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
    unset CFLAGS
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

# make directories and WRF/WPS dependent libraries
echo ""
echo "INSTALL_LIBS_SERIAL IO: installing SERIAL I/O WRF dependent libraries"

cd $WRF_SCRIPTS/wrf

echo "INSTALL_LIBS_SERIAL_IO: cleaning ${WRF_SCRIPTS}/wrf/bin"
rm -rf bin
mkdir bin
cd bin
ln -s ../scripts/getdata_gfs.py
ln -s ../scripts/runwrf
cd ../

echo "INSTALL_LIBS_SERIAL_IO: cleaning ${WRF_SCRIPTS}/wrf/include"
rm -rf include
mkdir include

echo "INSTALL_LIBS_SERIAL_IO: cleaning ${WRF_SCRIPTS}/wrf/lib"
rm -rf lib
mkdir lib

echo "INSTALL_LIBS_SERIAL_IO: cleaning ${WRF_SCRIPTS}/wrf/log"
rm -rf log
mkdir log

echo "INSTALL_LIBS_SERIAL_IO: cleaning ${WRF_SCRIPTS}/wrf/share"
rm -rf share
mkdir share

mkdir -p gfs_0.25 output

echo "INSTAll_LIBS_SERIAL_IO: if this is a re-build (not a cloned install) then directories:"
echo "         gfs_0.25"
echo "         output"
echo "         sectors"
echo "         WPS_GEOG"
echo ""
echo "are preserved."

# HDF5
# you can download HDF5 from the HDF5 download page.
# Go to https://www.hdfgroup.org/downloads/hdf5
# Scroll down and click on "Specific release?"    
# download and put into the tarball into ${WRF_SCRIPTS}/packages
clear_vars
PNAME=hdf5-1.10.10
SUFFIX=tar.bz2
CONF_PARAMS="--prefix=${WRF_SCRIPTS}/wrf --enable-fortran"
make_lib

# wget https://downloads.unidata.ucar.edu/netcdf-c/4.9.2/netcdf-c-4.9.2.tar.gz
clear_vars
PNAME=netcdf-c-4.9.2
SUFFIX=tar.gz
CONF_PARAMS="--prefix=${WRF_SCRIPTS}/wrf --enable-netcdf4 --disable-byterange --enable-largefile"
export CPPFLAGS=-I$WRF_SCRIPTS/wrf/include
export LDFLAGS=-L$WRF_SCRIPTS/wrf/lib
make_lib

# wget https://downloads.unidata.ucar.edu/netcdf-fortran/4.6.1/netcdf-fortran-4.6.1.tar.gz
clear_vars
PNAME=netcdf-fortran-4.6.1
SUFFIX=tar.gz
CONF_PARAMS="--prefix=${WRF_SCRIPTS}/wrf --enable-largefile --enable-shared"
export CPPFLAGS=-I$WRF_SCRIPTS/wrf/include
export LDFLAGS=-L$WRF_SCRIPTS/wrf/lib
export FC=gfortran
make_lib

# source URL for mpich
# https://www.mpich.org/downloads/
# install MPICH or OPENMP
clear_vars
if [[ ${INSTALL_WRF_MPI} == "MPICH" ]]
then
    PNAME=mpich-4.2.1         # package name
    SUFFIX=tar.gz
    
    # compile with CUDA?
    echo "INSTALL_LIBS_SERIAL_IO: using INSTALL_WRF_USE_CUDA=${INSTALL_WRF_USE_CUDA}"
    if [[ ${INSTALL_WRF_USE_CUDA} == "NONE" ]]
    then
        CUDA="--without-cuda"
        echo "INSTALL_LIBS_SERIAL_IO: compiling MPICH without CUDA"
    else
        if [[ -d ${INSTALL_WRF_USE_CUDA} ]] # check directory 
        then
            CUDA="--with-cuda=${INSTALL_WRF_USE_CUDA}"
            echo "INSTALL_LIBS_SERIAL_IO: compiling MPICH with CUDA=${INSTALL_WRF_USE_CUDA}"
        else
            echo "INSTALL_LIBS_SERIAL_IO: CUDA directory ${INSTALL_WRF_USE_CUDA} does not exist...exiting"
            exit 1
        fi
    fi

    # MAC OS ?
    if [[ ${OSTYPE} == "darwin"* ]]
    then
        echo "INSTALL_LIBS_SERIAL_IO: compiling MPICH for MAC OS X"

	GNUBIN=/opt/local/bin
	
	export FC=$GNUBIN/gfortran
	export F77=$FC
	echo "FC=${FC} F77=${F77}"
	
	export CC=$GNUBIN/gcc
	export CXX=$GNUBIN/g++

	echo "CC=${CC} CXX=${CXX}"

        export FFLAGS="-fPIC -m64 -fallow-argument-mismatch -I /opt/local/include/unistring/cdefs.h"
        export CFLAGS="-fPIC -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64 -m64 -I /opt/local/include/unistring/cdefs.h"

	CONF_PARAMS="--prefix=${WRF_SCRIPTS}/wrf --enable-shared=no --enable-fast=O3,ndebug --disable-error-checking --enable-fortran=all --enable-cxx --enable-romio"

        #export CC=gcc 
        #export CFLAGS="-fcommon -Wno-error=incompatible-pointer-types"
        #export CXXFLAGS="-fcommon -Wno-error=incompatible-pointer-types"
	#-Wincompatible-pointer-types
        #CONF_PARAMS="--prefix=${WRF_SCRIPTS}/wrf --with-device=ch4:ucx " # no CUDA or DEVICE for now
    else
        
        echo "INSTALL_LIBS_SERIAL_IO: compiling MPICH with channel ${INSTALL_WRF_IO_CHANNEL}"
        
        # TODO:check for valid device
        DEVICE="--with-device=${INSTALL_WRF_IO_CHANNEL}"
        CONF_PARAMS="--prefix=${WRF_SCRIPTS}/wrf ${CUDA} ${DEVICE}"
    fi
    
    make_lib
fi

# source URL for openmpi?
if [[ ${INSTALL_WRF_MPI} == "OPENMP" ]]
then
    # check if libgomp and mpirun exist
    
    # if not then compile OPENMP
    echo "INSTALL_LIBS_SERIAL_IO: compiling OPENMP"
    PNAME=openmpi-5.0.3
    SUFFIX=tar.bz2
    
    CONF_PARAMS="--prefix=${WRF_SCRIPTS}/wrf"
    make_lib
fi

echo "Installing SERIAL I/O WRF dependent libraries done"
