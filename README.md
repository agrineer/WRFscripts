WRFscripts, is a GNU/Linux and Python package meant to facilitate the installation and execution of the Weather, Research, and Forecasting (WRF) model from NCAR/UCAR. This package compiles and installs libraries for WRF-ARW and WRF-ARW itself, and provides shell and Python scripts needed to run WRF-ARW on an automated basis.

WRFscripts is intended to show data science students how large data sets can be generated and managed. It is also being used for research projects involving weather and climate.

The approach is to separate out different geographic sectors from the main WRF working directory with the use of file links, so that each sector retains its own input and output while using only one WRF installation. Simultanoues runs can also be done for different mesoscale sectors.

Once the user has settled on parameter values for WRF (sectors,namelists,etc) the processing can be automated using the scheduler "cron." This package is hindcast oriented but forcasting can also be done with the appropriate Global Forecast System (GFS) files.

This package can be run on desktops, preferably multi-core, as well as on High Performance Computers (HPC) using SLURM.

Currently implementing WRFV4.7.0 and WPS-4.6.0 versions.

Software: GNU/Linux, Python 3.8 or greater, developer environment with gfortran, etc. 
          Developed using Linux Mint 22.1 Xia 64-bit, Kernel 6.8.0-137-generic_x86_64, AMD FX-8350 8 core, 32GB

Skills: Terminal command line navigation.

