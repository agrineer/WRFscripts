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

INSTALL_LIBS_SERIAL_IO_copyright="INSTALL_LIBS_SERIAL_IO Copyright (c) 2020-2026 Scott L. Williams released under GNU GPL V3.0"

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
        echo "                        review ${WRF_SCRIPTS}/wrf/packages/${PNAME}/${PNAME}_config.log"
        echo "                        and ${WRF_SCRIPTS}/wrf/packages/${PNAME}/config.log for details"
        exit 1
    fi
}

# test and report make
check_make()
{
    if [[ ${PIPESTATUS[0]} -gt 0 ]]
    then
        echo "INSTALL_LIBS_SERIAL_IO: could not make ${PNAME}"
        echo "                        review ${WRF_SCRIPTS}/wrf/packages/${PNAME}/${PNAME}_make.log for details"
        exit 1
    fi
}

# test and report make install
check_make_install()
{
    if [[ ${PIPESTATUS[0]} -gt 0 ]]
    then
        echo "INSTALL_LIBS_SERIAL_IO: could not make install ${PNAME}"
        echo "                        review ${WRF_SCRIPTS}/wrf/packages/${PNAME}/${PNAME}_make_install.log for details"
        exit 1
    fi
}

print_env()
{
    echo ""
    echo "INSTALL_LIBS_SERIAL_IO: installing ${PNAME} with these variable values and flags:"

    # print variable if populated
    
    if [[ -n ${CPPFLAGS} ]];   then echo "  CPPFLAGS=${CPPFLAGS}"; fi
    if [[ -n ${FC} ]];         then echo "  FC=${FC}"; fi
    if [[ -n ${LDFLAGS} ]];    then echo "  LDFLAGS=${LDFLAGS}"; fi
    if [[ -n ${WITH_CMAKE} ]]; then echo "  WITH_CMAKE=${WITH_CMAKE}"; fi

    echo "  CONF_PARAMS=${CONF_PARAMS}"  # must always have CONF_PARAMS
    echo ""

    if [[ -n ${GCC} ]];      then echo "  GCC=${GCC}"; fi
    if [[ -n ${GNUBIN} ]];   then echo "  GNUBIN=${GNUBIN}"; fi
    if [[ -n ${SDKROOT} ]];  then echo "  SDKROOT=${SDKROOT}"; fi
    #if [[ -n ${FC} ]];       then echo "  FC=${FC}"; fi
    if [[ -n ${F77} ]];      then echo "  F77=${F77}"; fi
    if [[ -n ${FCFLAGS} ]];  then echo "  FCFLAGS=${FCFLAGS}"; fi
    if [[ -n ${CLANG} ]];    then echo "  CLANG=${CLANG}"; fi
    if [[ -n ${FLANG} ]];    then echo "  FLANG=${FLANG}"; fi
    if [[ -n ${CFLAGS} ]];   then echo "  CFLAGS=${CFLAGS}"; fi
    if [[ -n ${CXXFLAGS} ]]; then echo "  CXXFLAGS=${CXXFLAGS}"; fi
    #if [[ -n ${LDFLAGS} ]];  then echo "  LDFLAGS=${LDFLAGS}"; fi
}

make_lib()
{
    print_env
    
    cd $WRF_SCRIPTS/packages
    rm -rf $PNAME # remove old package dir

    untar_package # parameters are PNAME and SUFFIX
    cd $PNAME
   
    if [[ -n ${WITH_CMAKE} ]] && [[ ${WITH_CMAKE} == "YES" ]]
    then
	echo "INSTALL_LIBS_SERIAL_IO: configuring library ${PNAME} on ${HOSTNAME} with cmake"
	mkdir build && cd build
	cmake $CONF_PARAMS ..
	check_configure

	echo "INSTALL_LIBS_SERIAL_IO: building library ${PNAME} on ${HOSTNAME} with cmake"
	cmake --build .
	check_make

	echo "INSTALL_LIBS_SERIAL_IO: installing library ${PNAME} on ${HOSTNAME} with cmake"
	cmake --install .
	check_make_install
    else
	echo "INSTALL_LIBS_SERIAL_IO: configuring library ${PNAME} on ${HOSTNAME} with ./configure"
	./configure $CONF_PARAMS 2>&1 | tee $PNAME\_config.log
	check_configure

	echo "INSTALL_LIBS_SERIAL_IO: making library ${PNAME} on ${HOSTNAME} with make"
	make -j $INSTALL_WRF_NUM_CORES 2>&1 | tee $PNAME\_make.log
	check_make
    
	echo "INSTALL_LIBS_SERIAL_IO: installing library ${PNAME} on ${HOSTNAME} with make install"
	make install 2>&1 | tee $PNAME\_make_install.log
	check_make_install
    fi
    
    echo "INSTALL_LIBS_SERIAL_IO: installing library ${PNAME} done"
}

# clear all environment variables used in this script
clear_vars()
{
    unset CONF_PARAMS
    unset CPPFLAGS
    unset FC
    unset LDFLAGS
    unset PNAME
    unset SUFFIX
    unset WITH_CMAKE

    unset GCC
    unset GNUBIN
    unset SDKROOT
   #unset FC
    unset F77
    unset CFLAGS
    unset CLANG
    unset FLANG
    unset CFLAGS
    unset CXXFLAGS
   #unset LDFLAGS
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
ln -s ../scripts/getarch_gfs.py
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

# --------------------------------------------------------------------
# HDF5

clear_vars

WITH_CMAKE=YES
PNAME=hdf5-2.2.0
SUFFIX=tar.gz
CONF_PARAMS="--install-prefix=${WRF_SCRIPTS}/wrf\
 -DBUILD_TESTING=OFF\
 -DHDF5_BUILD_TOOLS=ON\
 -DHDF5_ENABLE_ZLIB_SUPPORT=ON\
 -DBUILD_SHARED_LIBS=ON\
 -DHDF5_BUILD_FORTRAN=ON"
# DHDF5_PROVIDES_PARALLEL:BOOL=ON

make_lib

#--------------------------------------------------------------------
# NETCDF

clear_vars

PNAME=netcdf-c-4.10.1
SUFFIX=tar.gz
CONF_PARAMS="--prefix=${WRF_SCRIPTS}/wrf --enable-netcdf4 --disable-byterange --enable-largefile"
export CPPFLAGS="-I${WRF_SCRIPTS}/wrf/include"
export LDFLAGS="-L${WRF_SCRIPTS}/wrf/lib"

make_lib

#---------------------------------------------------------------------
# NETCDF-Fortran

clear_vars

PNAME=netcdf-fortran-4.6.4
SUFFIX=tar.gz
CONF_PARAMS="--prefix=${WRF_SCRIPTS}/wrf --enable-largefile --enable-shared --disable-zstandard-plugin"
export CPPFLAGS="-I${WRF_SCRIPTS}/wrf/include"
export LDFLAGS="-L${WRF_SCRIPTS}/wrf/lib -lnetcdf"
export FC=gfortran

make_lib

#-------------------------------------------------------------
# MPICH

clear_vars

if [[ ${INSTALL_WRF_MPI} == "MPICH" ]]
then
    PNAME=mpich-5.0.2         # package name
    SUFFIX=tar.gz
    
    # compile with CUDA?
    echo "INSTALL_LIBS_SERIAL_IO: using INSTALL_WRF_USE_CUDA=${INSTALL_WRF_USE_CUDA}"
    if [[ ${INSTALL_WRF_USE_CUDA} == "NO" ]]
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
	# Make sure Apple’s developer tools are selected
	echo "INSTALL_LIBS_SERIAL_IO: Make sure Apple’s developer tools are selected..."
	sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer # sudo ?

	echo "INSTALL_LIBS_SERIAL_IO: compiling MPICH for MAC OS X ${OSTYPE} with: "

	# Identify the GNU bin directory.
	export GCC=`which gcc`
	export GNUBIN=`dirname $GCC`

	# Add the SDKROOT environment variable to
	# reconfigure with Apple frameworks available to the linker.
	export SDKROOT="$(xcrun --sdk macosx --show-sdk-path)"
	
	export FC=`which gfortran`
	export F77=`which gfortran`
	export FCFLAGS="-m64 -fallow-argument-mismatch"
	export FLANG=`which flang`
	
	export CLANG=`which clang`
	export CFLAGS="-w -fPIE -Wno-implicit-function-declaration -I${SDKROOT}/usr/include"
	export CXXFLAGS="-w -fPIE -Wno-implicit-function-declaration -I${SDKROOT}/usr/include"
	export LDFLAGS="-Wl,-framework,CoreFoundation -Wl,-framework,IOKit"

        CONF_PARAMS="--prefix=${WRF_SCRIPTS}/wrf" # no CUDA or DEVICE for now
    else
        
        echo "INSTALL_LIBS_SERIAL_IO: compiling MPICH with channel ${INSTALL_WRF_IO_CHANNEL}"
        
        # TODO:check for valid device
        DEVICE="--with-device=${INSTALL_WRF_IO_CHANNEL}"
        CONF_PARAMS="--prefix=${WRF_SCRIPTS}/wrf ${CUDA} ${DEVICE}"
    fi
    
    make_lib
fi

echo "Installing SERIAL I/O WRF dependent libraries done"
