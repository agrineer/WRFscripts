WRFscripts is a package meant to facilitate the installation and execution of the Weather, Research, and Forecasting (WRF) model and runs on desktop GNU/Linux, MAC OS/X, and SLURM GNU/Linux HPC platforms. This package compiles and installs libraries for WRF-ARW and WRF-ARW itself, and provides shell and Python scripts to run WRF-ARW on an automated or manual basis.

WRFscripts is intended to show data science students how large data sets can be generated and managed. It is also being used for research projects involving weather and climate (see github.com/agrineer/eto).

The approach is to separate out different geographic sectors (domains) from the main WRF working directory with the use of file links, so that each sector retains its own input and output while using only one WRF installation. Simultanoues runs can also be done for different sectors.

Once the user has settled on parameter values for WRF (domains,namelists,etc) the processing can be automated using the scheduler "cron." This package is hindcast oriented but forcasting can also be done with the appropriate Global Forecast System (GFS) files.

Currently implementing WRF-4.8.0 and WPS-4.7.0 versions with HDF5-2.2.0, NetCDF-C-4.10.1, and NetCDF-4.6.4-Fortran libraries.

Software used:

* Python 3.8 or greater, developer environment with GNU suite, cmake, etc. 
* Developed using Mint 22.1 Xia 64-bit, Kernel 6.8.0-137-generic_x86_64, AMD FX-8350 8 core, 32GB
* SLURM with Ubuntu 24.04.5 LTS (GNU/Linux 6.8.0-136-generic x86_64)
* Darwin Kernel Version 27.0.0 RELEASE_ARM64_T6041 arm64

Skills: GNU/Linux or UNIX terminal navigation and shell commands.

To install: After cloning or untar'ing, go to WRFscripts/install and follow directions in HOWTO_INSTALL.txt

PLEASE NOTE: Under development.

