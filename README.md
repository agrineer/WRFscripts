
Description

WRFscripts, GNU/Linux and Python, package is meant to facilitate the installation and
execution of the Weather, Research, and Forecasting (WRF) model from NCAR/UCAR.
This package gives the shell and Python scripts needed to run WRF/ARW on an automated basis.

It is intended to show data science students how large data sets can be
generated and managed. It is also being used for research projects
involving weather and climate.

The approach is to separate out different geographic sectors from the main
WRF working directory with the use of file links, so that each sector retains its
own input and output while using only one WRF installation. Simultanoues
runs can also be done for different sectors.

This package can be run on desktops as well as on High Performance Computers
(HPC) using SLURM. Relevant software is bundled and compiled during
installation to ensure compatible version implementation.

Once the user has settled on parameter values for WRF (sectors,namelists,etc)
the processing can be automated using cron. This package is hindcast oriented
but forcasting can also be done with the appropriate Global Forecast System
(GFS) files.

Currently implementing WRFV4.7.0 and WPS-4.6.0 versions.

Software: GNU/linux, Python 3.8 or greater, developer environment (build_essentials, etc), gfortran

Skills: Terminal command line navigation