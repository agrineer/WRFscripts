#!/usr/bin/python3

'''
@file wrfGFS.py
@author Scott L. Williams.
@package WRF
@brief implements Weather, Research, and Forecast (WRF) runs
@LICENSE
# 
#  wrfGFS.py Copyright (C) 2016-2025 Scott L. Williams.
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
#

@sections DESCRIPTION
implements daily WRF runs based on distinctly specified geographical sectors (highest domain resolution) using the same working WRF directory through the magic of file linking.

takes care of: which platforms to use (eg. SLURM, MPICH)
               ungrib, metgrib (union of static and dynamic data)
               editing WPS and WRF namelist files for given dates
               spin-up restarting
'''

wrfGFS_pycopyright = 'wrfGFS.py Copyright (c) 2016-2025 Scott L. Williams ' + \
            'released under GNU GPL V3.0'

# gfs wrf run 

import os
import sys
import glob
import time
import getopt
import datetime

# print functions to reduce clutter and to flush output
def eprint( *args ):
    print( 'wrfGFS: ', file=sys.stderr, flush=True, end='' ) 
    print( *args, file=sys.stderr, flush=True)

def oprint( *args ):
    print( *args, file=sys.stdout, flush=True)

# print out exit message
def print_and_exit( *args ):
    eprint( *args )
    sys.exit( 2 )

# run system command and exit if fails
def os_command( command ):
    eprint( 'running command: ' + command )
    status = os.system( command )
    if status != 0:
        print_and_exit( 'something went wrong...cannot run command:', command  )

# return days to use from date
def get_days( date ):

    if date == None:

        # run wrf with yesterday's data, instantiate data objects
        nday = datetime.datetime.utcnow()
        rday = nday - datetime.timedelta( days=1 )

    else :

        yr = int( date[:4] )
        mn = int( date[4:6] )
        dy = int( date[6:8] )

        # instantiate date objects
        rday = datetime.date( yr,mn,dy )
        nday = rday + datetime.timedelta( days=1 )

    return rday, nday

# remove old temporary files
def clean_wpsdir( rsector, prefix ):

    # go to WPS dir
    os.chdir( rsector + '/wps')

    pstar = prefix + '*'
    for f in glob.glob( pstar ):
        os.remove( f )
        
    for f in glob.glob( 'GRIBFILE*' ):
        os.remove( f )
        
    for f in glob.glob( 'PFILE*' ):
        os.remove( f )
        
    for f in glob.glob( 'met_em.d*' ):
        os.remove( f )

# create new namelist.wps file from SECTOR/wps/namelist.wps.template
# with this run's dates
def new_wps_namelist( rsector, rday, nday, begin ):

    os.chdir( rsector + '/wps' )

    # must already be in the sector's wps directory
    if os.path.isfile( 'namelist.wps.old' ):
        os.remove( 'namelist.wps.old' )

    if os.path.isfile( 'namelist.wps' ):
        os.rename( 'namelist.wps', 'namelist.wps.old' )

    try:
        fin = open( 'namelist.wps.template', 'r' )
        fout = open( 'namelist.wps', 'w' )
        
    except Exception as e:
        print_and_exit( str(e) )

    # get number of WRF defined domains and temporary file prefix
    # TODO: make more robust eg, what if no space between line items
    for line in fin :
        
        if line.find( 'max_dom' ) != -1:
            items = line.split(' ')
            ndoms = int( items[3][:1] )
            eprint( 'WPS is using:', ndoms, 'domains' )
 
        if line.find( 'prefix' ) != -1:
            items = line.split(' ')
            prefix = str(items[3])

            # prefix.strip( ',' ) doesn't work for some reason
            prefix = prefix[:-3]
            prefix = prefix[1:]
            eprint( 'WPS is using temporary prefix:', prefix )
   
    fin.seek( 0 ) # reset file pointer
    
    sformat = '%Y-%m-%d_' + '%02d'%begin + ':00:00' # has to have colons for WRF
    sd = rday.strftime( sformat ) 
    ed = nday.strftime( sformat )

    # edit in dates to use in this WRF run
    for line in fin :
        
        if line.find( 'start_date' ) != -1:

            # start date string construction 
            start_str = ' start_date = '
            for d in range( 0, ndoms ):
                start_str = start_str + "'" + sd +  "', "
                
            fout.write( start_str + '\n' )
            
        elif line.find( 'end_date' ) != -1:
            
            # end date string construction 
            end_str = ' end_date   = '
            for d in range( 0, ndoms ):
                end_str = end_str + "'" + ed +  "', "
                
            fout.write( end_str + '\n' )
            
        else:
            fout.write( line )  # keep other values the same

    fout.close()
    fin.close()

    return ndoms, prefix

# run ungrib in sector/wps directory
def ungrib():

    # check for previous ungrib log
    if os.path.isfile( 'ungrib.log' ):
        os.remove( 'ungrib.log' )

    # ungrib and check results
    os_command( './ungrib.exe' )

    # FIXME: ungrib time interpolation between forcing files does not work.
    # NOTE: just as well that the start hour has to align with a forcing
    #       files's hour since the intermediate hour requires an interpolation
    #       most likely reducing accuracy, but it would be nice to have it work
    #       as advertised.
    
    # check if successful
    fin = open( 'ungrib.log', 'r' )
    for line in fin:
        if line.find( 'Successful completion of program ungrib.exe') != -1:
            eprint( line )        # found
            fin.close()
            return
    fin.close()

    # not found
    ostr = 'UNSUCCESSFUL completion of program ungrib.exe, ' + \
           'check ungrib.log file in sectors wps directory'
    print_and_exit( ostr )

# run metgrid in sector/wps directory
def metgrid():

    # check for previous metgrid log
    if os.path.isfile( 'metgrid.log' ):
        os.remove( 'metgrid.log' )

    # check if successful
    os_command( './metgrid.exe' )
    fin = open( 'metgrid.log', 'r' )
    for line in fin:
        if line.find( 'Successful completion of program metgrid.exe' ) != -1:
            eprint( line )
            fin.close()
            return
    fin.close()

    # not found
    ostr = 'UNSUCCESSFUL completion of program metgrid.exe, ' + \
           'check metgrid.log file in sectors wrf directory'
    print_and_exit( ostr )

def write_wrf_dates( fout, prefix, value, ndoms ):
    
    s = prefix
    for i in range( ndoms ):
        s = s + value
    s = s + '\n'
        
    fout.write( s )
 
# create wrf namelist from template with this run's dates
def new_wrf_namelist( rday, nday, begin, ndoms ):

    # edit namelist.input.template

    # split up start and end dates
    syr = rday.strftime( '%Y, ' )
    smn = rday.strftime( '%m, ' )
    sdy = rday.strftime( '%d, ' )
    shr = '%02d'%begin + ', '

    eyr = nday.strftime( '%Y, ' )
    emn = nday.strftime( '%m, ' )
    edy = nday.strftime( '%d, ' )
    ehr = shr

    if os.path.isfile( 'namelist.input.old' ) :
        os.remove( 'namelist.input.old' )

    if os.path.isfile( 'namelist.input' ) :
        os.rename( 'namelist.input','namelist.input.old' )

    fin = open( 'namelist.input.template', 'r' )
    fout = open( 'namelist.input', 'w' )

    # set the start and end dates 
    for line in fin :
        if line.find( 'run_hours' ) != -1 :
            fout.write( ' run_hours = 24,\n' )
            
        elif line.find( 'start_year' ) != -1 :
            write_wrf_dates( fout, ' start_year = ', syr, ndoms )
             
        elif line.find( 'start_month' ) != -1 :
            write_wrf_dates( fout, ' start_month = ', smn, ndoms )
            
        elif line.find( 'start_day' ) != -1 :
            write_wrf_dates( fout, ' start_day = ', sdy, ndoms )
           
        elif line.find( 'start_hour' ) != -1 :
            write_wrf_dates( fout, ' start_hour = ', shr, ndoms )
           
        elif line.find( 'end_year' ) != -1 :
            write_wrf_dates( fout, ' end_year = ', eyr, ndoms )
           
        elif line.find( 'end_month' ) != -1 :
            write_wrf_dates( fout, ' end_month = ', emn, ndoms )
           
        elif line.find( 'end_day' ) != -1 :
            write_wrf_dates( fout, ' end_day = ', edy, ndoms )
           
        elif line.find( 'end_hour' ) != -1 :
            write_wrf_dates( fout, ' end_hour = ', ehr, ndoms )

        #elif line.find( 'interval_seconds' ) != -1 :
        #    fout.write( ' interval_seconds = 21600\n' ) # 6hr input data
        #elif line.find( 'num_metgrid_levels' ) != -1 :
        #    fout.write( ' num_metgrid_levels                  = 27\n' )
        else :
            fout.write(line)

    fout.close()
    fin.close()

def clean_wrfdir( rsector, rsl ):

    # go to WRF dir
    os.chdir( rsector + '/wrf')

    # remove old status files
    for f in glob.glob( 'rsl.out*' ):
        os.remove( f )

    if ( rsl ):
        for f in glob.glob( 'rsl.error.*' ):
            os.remove( f )

    # remove any old output files
    for f in glob.glob( 'wrfout_d0*' ):
        os.remove( f )

    for f in glob.glob( 'met_em.d0*' ):
        os.remove( f )

    for f in glob.glob( 'wrfbdy_d0*' ):
        os.remove( f )

    for f in glob.glob( 'wrfinput_d0*' ):
        os.remove( f )

    for f in glob.glob( 'rsl.log' ):
        os.remove( f )

def run_real():

    eprint( 'running real.exe...' )
    os_command( './real.exe' )

    # check if successful
    try:
        fin = open( 'rsl.out.0000', 'r' )
    except:
        print_and_exit( 'cannot open rsl.error.0000' )
        
    for line in fin :
        if line.find( 'SUCCESS COMPLETE REAL_EM' ) != -1:
            eprint( line )  # found
            fin.close()
            return

    fin.close()

    ostr = 'UNSuccessful completion of program real.exe, check rsl.error.0000'
    print_and_exit( ostr )

# run wrf.exe according to environmental variable values (slurm or mpich)
def run_wrf( wrf_home, rdir, wrf_mpi, wrf_jcl, rsector ):

    eprint( 'running wrf.exe...' )

    # this is deprecated
    #os.system( 'salloc -N %d --exclude=imbabura0086 --ntasks-per-node %d /usr/bin/mpiexec ./wrf.exe'%(nnodes,ntasks) )

    # environment variables determine how to run wrf.exe
    # TODO: complete implementations
    if (wrf_mpi == 'MPICH') and (wrf_jcl == 'NONE'):
        eprint( 'using MPICH without job control language (JCL)' )
        mpich_hosts = get_mpich_hosts()
        os_command( 'mpiexec -hostfile ' + mpich_hosts + ' ./wrf.exe' )
        
    elif (wrf_mpi == 'OPENMP') and (wrf_jcl == 'NONE'):
        ncores = os.environ[ 'WRF_OPENMP_NCORES' ]
        eprint( 'using OPENMP without job control language (JCL)' )
        os_command( 'mpirun -np ' + ncores + ' ./wrf.exe' )

    elif (wrf_mpi == 'MPICH') and (wrf_jcl == 'SLURM'):
        eprint( 'using SLURM and MPICH' )
        
        # for slurm configuration edit ~/wrf/scripts/wrf_xxxx.slurm
        os_command( 'sbatch --wait ' +  rsector + '/wrf_mpich.slurm' )

    # TODO: include more modalities
    else:
        print_and_exit( 'unknown compute modality MPI=', 
                        wrf_mpi + ' and JCL=' + mpi_jcl )
                
    # check if all tasks report success
    rsl_error_files = glob.glob( 'rsl.error.*' )  # return session error
                                                  # filename array
    # get number of task report files
    nfiles = len( rsl_error_files )

    # should see "SUCCESS COMPLETE WRF" in each task error report file,
    # just count
    nfound = 0
    for f in rsl_error_files:   
        rsl = open( f, 'r' )

        for line in rsl:
            if line.find( 'SUCCESS COMPLETE WRF' ) != -1:
                nfound += 1
                break
            
        rsl.close()

    # number of found "SUCCESS COMPLETE WRF" should be the same as the number
    # of rsl.error.* files
    if nfound == nfiles:
        ostr = 'SUCCESSFUL completion of program wrf.exe ' + \
                datetime.datetime.now().isoformat()
        eprint( ostr )

    else:
        ostr = 'UNSUCCESSFUL completion of program wrf.exe ' + \
                datetime.datetime.now().isoformat()
        print_and_exit( ostr )

def get_jcl_env_variable( rsector ):
    
    known_jcl = [ 'PBS', 'SLURM', 'NONE' ]  # HPC job control
    
    # get JCL to run on
    try:
        wrf_jcl = os.environ[ 'WRF_JCL' ]
    except:
        print_and_exit( 'cannot retrieve WRF_JCL environment variable:',
                        '\neg: export WRF_JCL=SLURM' )

    if wrf_jcl not in known_jcl:
        print_and_exit( 'JCL is unknown:', wrf_jcl, 
                        '\nknown JCLs are :', known_jcl,
                        '\neg: export WRF_JCL=SLURM' )

    if wrf_jcl == 'SLURM':
        
        # check for slurm script file
        # TODO: check if mpich or openmp
        slurm_file = rsector + '/wrf_mpich.slurm'
        if not os.path.isfile( slurm_file ):
            print_and_exit( 'cannot find SLURM file:', slurm_file )

    if wrf_jcl == 'PBS':
        
        # check for PBS script file
        pbs_file = rsector + '/wrf.pbs'
        if not os.path.isfile( pbs_file ):
            print_and_exit( 'cannot find PBS file:', pbs_file )
 
    return wrf_jcl

def get_mpi_env_variable():
    
    known_mpi = [ 'MPICH','OPENMP', 'MPICH+OPENMP' ] # MPI's
    
    # get message passing scheme
    try:
        wrf_mpi = os.environ[ 'WRF_MPI' ]
    except:
        print_and_exit( 'cannot retrieve WRF_MPI environment variable', 
                        '\neg: export WRF_MPI=MPICH' )

    if wrf_mpi not in known_mpi:
        print_and_exit( 'MPI is unknown:', wrf_mpi, 
                        '\nknown MPIs are :\n', known_mpi,
                        '\neg: export WRF_MPI=MPICH' )          
    return wrf_mpi

# get MPICH environment variables
def get_mpich_hosts():
        
    try:
        # get MPICH available hosts
        mpich_hosts = os.environ[ 'WRF_MPICH_HOSTS' ]
        
    except:
        print_and_exit( 'environment variable WRF_MPICH_HOSTS is invalid:',
                        '\nset host file:', 
                        '\neg. export WRF_MPICH_HOSTS=/home/user/mpi.hosts')
        
    if not os.path.isfile( mpich_hosts ):
        print_and_exit( 'MPICH host file is not valid:', mpich_hosts,
                        '\nset host file:',
                        '\neg. export WRF_MPICH_HOSTS=/home/user/mpi.hosts')
            
    return mpich_hosts

# read WRF environment variables
def get_directories():

    # get WRF home directory
    wrf_home = os.environ[ 'WRF_HOME' ]
            
    # set WRF sectors
    sectors_dir = wrf_home + '/sectors'
    if not os.path.isdir( sectors_dir ):
        print_and_exit( 'WRF_HOME sectors directory:', sectors_dir, ' is invalid' )
    
    log_dir = wrf_home + '/log'
    if not os.path.isdir( log_dir ):
        print_and_exit( 'WRF_HOME log directory:', log_dir, ' is invalid' )
    
    out_dir = wrf_home + '/output'
    if not os.path.isdir( out_dir ):
        print_and_exit( 'WRF_HOME output directory:', out_dir, ' is invalid' )

    return wrf_home, sectors_dir, log_dir, out_dir

# announce processing start
def report_start_processing( gfs_dir, rsector, rdir ):
    
    ostr = 'starting run at local time:' + datetime.datetime.now().isoformat()
    eprint( ostr )

    ostr = 'using input data directory: ' + gfs_dir
    eprint( ostr )

    ostr = 'running wps/wrf on ' + rsector + ' for UTC date ' + rdir
    eprint( ostr )

def run_wps( rsector, rdir, ndir, gfs_dir ):

    os.chdir( rsector + '/wps' )

    ddir = gfs_dir + '/'

    # points to directories spanning 2 days to find GFS files
    gdirs = ddir + rdir + '/* ' + ddir + ndir + '/* '
    os_command( './link_grib.csh ' + gdirs ) # link GFS grib files
                                             # to wps directory

    # ready to run wps routines
    ungrib()
    metgrid()

def check_if_running( log_dir, sector ):
    
    lockpath = log_dir + '/running_' + sector + '.lock'
    if os.path.isfile( lockpath ) :
        print_and_exit( 'wrf already running or crashed.' )
    else:
        os_command( 'touch ' + lockpath )

    return lockpath

def start_wrf( rsector, rday, nday, begin, rdir, ndoms ):

    directory = rsector + '/wrf'
    os.chdir( directory )

    # link up WPS files
    os_command( 'ln -s  ' + rsector + '/wps/met_em.d0* .' )

    # edit namelist for rundate
    new_wrf_namelist( rday, nday, begin, ndoms )

    run_real()

def fix_names( wdir ):
    
    os.chdir( wdir )

    # replace time section of filename to have '-' instead of '_' or ':'
    # gdal cannot parse names with ':' and pnetcdf puts '_' in string
    # we want all output names to have the same format
    for f in glob.glob( 'wrfout_d*' ):

        newfile = f[:-6]             # remove minutes and seconds
        newfile = newfile + '-'      # add the hyphen
        newfile = newfile + f[-5:-3] # add the minutes
        newfile = newfile + '-'
        newfile = newfile + f[-2:]   # add the seconds
        os.rename( f, newfile )

# move output files from sector/wrf to $WRF_HOME/output
def store_output( out_dir, sector, rday, nday, begin, ndoms ):

    runday_dir = rday.strftime( "%Y%m%d" )
    
    # store output files 
    out_path = out_dir + '/' + sector + '/' + runday_dir 
    if not os.path.exists( out_path ):
        os.makedirs( out_path )

    os_command( 'mv wrfout_d0* ' + out_path )

    # move next day's restart files, if any, to out directory
    nstamp = nday.strftime( "%Y-%m-%d" ) + '_%02d'%begin + '_00_00'
  
    for i in range( 1, ndoms+1 ):
        
        f = 'wrfrst_d%02d'%i + '_' + nstamp
        if os.path.isfile( f ):
            os_command( 'cp ' + f + ' ' + out_path )

    # REMINDER: restart files (wrfrst*) are left in .../sectors/XXXXX/wrf from
    #           previous run and are also copied to rundate out directory
    #           if needed later

    # change time delimiters in output names
    fix_names( out_path )

def clean_up( rsector, prefix, lockpath ):

    # do file housekeeping
    clean_wpsdir( rsector, prefix )
    clean_wrfdir( rsector,  False ) # False retains rsl.error files
                                    # for later inspection
    # remove lock file
    try:
        if os.path.isfile( lockpath ):
            os.remove( lockpath )
        else:
            eprint( 'lock file does not exist, ' +
                    'it may have been manually removed during run.' )
            eprint( 'does not affect run' )
    except:
        eprint( 'cannot remove lock file ', lockpath )

# edit template file for restart value
def edit_template( rs ):
    
    fin = open( 'namelist.input.template', 'r' )
    fout = open( 'namelist.input.template.restart', 'w' )

    # set the restart period in the namelist.input.template file
    for line in fin:
        if (line.find( 'restart ' ) != -1) or (line.find( 'restart=' ) != -1) :
            fout.write( ' restart = ' + rs +',\n' )
        else:
            fout.write( line )

    fout.close()
    fin.close()

    try:
        os.remove( 'namelist.input.template' )
        os.rename( 'namelist.input.template.restart',
                   'namelist.input.template' )
    except:
        print_and_exit( 'error in wrf template file removal or renaming' )

def check_restart_files( wrf_home, sector, rday, begin, ndoms ):
    
    # check for rundate's restart files
    # restart files should have been left by previous day's run in the
    # .../sectors/XXXXXX/wrf directory (working wrf)
    rstamp = rday.strftime( '%Y-%m-%d' ) + '_' + '%02d'%begin + '_00_00'
    rstfiles = []
    for i in range(1,ndoms+1):
        
        f = 'wrfrst_d%02d'%i + '_' + rstamp

        if not os.path.isfile( f ):  # should be in working wrf directory
                                     # but if not ...

            # check if file is in yesterday's output directory
            eprint( 'restart file ' + f + ' does not exist' )
            eprint( 'trying yesterdays output cache' )
            yday = rday - datetime.timedelta( days=1 )
            ydate = yday.strftime( '%Y%m%d')
 
            cache_file = wrf_home + '/output/' + sector + '/' + \
                         ydate + '/' + f
            
            if os.path.isfile( cache_file ):
                eprint( 'found restart file:', cache_file, '...copying' )
                os_command( 'cp ' + cache_file + ' .' )
                
            else:
                print_and_exit( 'could not find restart file:', f )
                
        rstfiles.append( f )
                  
    # remove unneeded restart files in .../sectors/XXXX/wrf directory
    for f in glob.glob( 'wrfrst*' ):
        if f not in rstfiles:
            eprint( 'removing unneeded restart file:', f )
            os.remove( f )

# setup whether continuing or initializing a long run       
def set_restart( sector, restart, rday, begin, ndoms ):

    # get working wrf directory
    wrf_home = os.environ[ 'WRF_HOME' ]
    wwrf = wrf_home + '/sectors/' + sector + '/wrf'
    eprint( 'working directory: ', wwrf )
    os.chdir( wwrf )
              
    if ( restart ):
        rs = '.true.'
    else:
        rs = '.false.'

    eprint( 'restart = ' + rs )

    edit_template( rs )
    
    if ( restart ):
        check_restart_files( wrf_home, sector, rday, begin, ndoms )
        
    else:

        # remove all restart files in working wrf directory
        for f in glob.glob( 'wrfrst*' ):
            
            eprint( 'removing restart file:', f )
            try:
                os.remove( f )
            except Exception as e:
                eprint( str(e) )
                print_and_exit( 'could not remove restart file:', f )
        
def usage():
    
    eprint( 'usage: wrfGFS.py -h -b hour -s sector -g gfsdir ' +
            '-r true/false -d rundate' )
    
    eprint( '       wrfGFS.py --help --begin=hour --sector=sectorname ' +
            '--gfsdir=gfsdir --restart=true/false --date=rundate')

    eprint( '       rundate has format YYYYMMDD' )
    eprint( '       if the --restart flag is true then the WRF run will ' +
            'use restart files')
    
    eprint( '       if the --restart flag is false then the WRF run will ' +
            'not use restart files and initiates a new run')
    
    eprint( '       begin hour is in UTC' )
    eprint( '       all arguments must be specified, except for -h, help' )
    
    sys.exit(2)  

## command line options parsing
##
## input :
##
##     argv : command line argument array
##
## returns:
##
##    begin : day's run begin hour in UTC, must be in integer range 0-18
##   sector : sector region to run, must be same name as in wrf/sectors
##   gfsdir : input directory for GFS files, UTC based
##  restart : continue from yesterday's run if true, initiate new run if false
##  rundate : run date to process in YYYYMMDD format
## 
def read_args( argv ):
    
    begin = None     # begin hour is in UTC
    sector = None    # specify sector region
    gfsdir = None    # input GFS files; UTC based
    restart = None   # continuous runs
    rundate = None   # run date to process YYYYMMDD format
 
    try:                                
        opts, args = getopt.getopt( argv,
                                    'hb:s:g:r:d:', 
                                    ['help','begin=','sector=',
                                     'gfsdir=','restart=','date='])
    except getopt.GetoptError as e:
        eprint( str(e) )
        eprint('unknown command arguments')
        usage()                          
                   
    for opt, arg in opts:

        if opt in ( '-h', '--help' ): 
            usage()                        

        elif opt in ( '-b', '--begin' ):
            begin = int(arg)
            if begin not in [0,6,12,18]:
                
                # only works with 00,06,12,18 values
                print_and_exit( 'begin hour must be one of 0,6,12,18' )
 
        elif opt in ( '-s', '--sector' ):
            sector = arg
        
        elif opt in ( '-g', '--gfsdir' ):
            if not os.path.isdir( arg ):
                print_and_exit( 'gfs directory:', arg, ' not found' )
            gfsdir = arg
        
        elif opt in ( '-r', '--restart' ):
            
            if arg in [ 'True','true', 'TRUE', 'T', 't' ]:
                restart = True
            elif arg in [ 'False','false', 'FALSE', 'F', 'f' ]:
                restart = False
            else:
                print_and_exit( 'unknown init flag value:', arg,
                                ' must be one of:', 
                                ' [True,true,TRUE,T,t,False,false,FALSE,F,f]' )

        elif opt in ( '-d', '--date' ):
            
            # naive checks
            if not ( len(arg) == 8 ):
                print_and_exit( 'rundate argument not YYYYMMDD format:',
                                ' rundate=', arg );
            try:
                test = int( arg )
            except:
                print_and_exit( 'rundate argument is not an integer:', arg )
                
            rundate = arg

    if begin == None:
        eprint('must have begin hour.')
        usage()                     

    if sector == None:
        eprint('must have sector name.')
        usage()  
    
    if gfsdir == None:
        eprint('must have input gfs data directory')
        usage()                     
    
    if restart == None:
        eprint('must have restart flag')
        usage()                     

    if rundate == None:
        eprint('must have rundate')
        usage()                     

    return begin, sector, gfsdir, restart, rundate

#####################################################################

## program start for wrfGFS.py
##
## This script runs the Weather, Research, and Forecast (WRF) model,
## from UCAR/NCAR, on a high level with a run scope of one day for input
## and output. It is part of the agrineerWRF implementation and should be
## run in that context. Continous daily runs can be specified where the 
## next daily run picks up from where the previous run left off, allowing
## for WRF 'spin-up'.
##
## In addition to command line arguments (see read_args() ) this script
## requires the following environment variables:
##
## WRF_HOME=/home/user/agrineerWRF/wrf        # or wherever agrineerWRF
##                                            # is installed
## WRF_MPI=MPICH                              # use a known MPI platform
## WRF_OPENMP_NCORES=NONE
## WRF_JCL=NONE
## WRF_MPICH_HOSTS=/home/user/mpd.hosts   # use this if WRF_MPI=MPICH
##
## This script uses pre-defined namelist files, which are set by the user
## in the sectors directory, and simply edits the files for the run dates
## given. It is the user's responsibity to define the WRF domains and
## parameters used in the namelist files (WPS/WRF) as in a regular WRF
## setup.
##
## Output from this script includes the domain wrfout* netcdf files, and
## if restarting, wrfrst* files for the next day's run. The time
## granularity can be set in the namelist files but it is usually to one hour.

if __name__ == '__main__':  

    __version__ = '0.1.0'
    eprint( 'STARTING WRF RUN:\n' )
   
    # get domain sector, run date, begin hour, input (gfs) data dir and
    # if to restart run
    begin, sector, gfs_dir, restart, rundate = read_args( sys.argv[1:] )
    eprint( '            version:', __version__    )
    eprint( 'arguments given are:'                 )
    eprint( '     UTC begin hour: ' + str(begin)   )
    eprint( '             sector: ' + sector       )
    eprint( '             gfsdir: ' + gfs_dir      )
    eprint( '            restart: ' + str(restart) )
    eprint( '            rundate: ' + rundate      )  

    # this code is dependent on several global environment variables
    wrf_home, sectors_dir, log_dir, out_dir = get_directories()

    try:
        build = open( wrf_home + '/build.conf' )
        for line in build:
            eprint( line.strip() )
        build.close()
    except:
        eprint( 'cannot open ' + wrf_home + '/build.conf ' + 'continuing...' )

    wrf_mpi = get_mpi_env_variable()

    # set the run sector
    rsector = sectors_dir + '/' + sector

    # get the job control language environment
    wrf_jcl = get_jcl_env_variable( rsector )
    
    # parse dates from rundate to get date objects 'rday' and next day, 'nday'
    rday,nday = get_days( rundate )

    # use these gfs data directories
    rday_dir = rday.strftime( "%Y%m%d" )
    nday_dir = nday.strftime( "%Y%m%d" )

    # if not already running wrf on this sector then set lock file

    # check for previous run and if not, set lock file
    lockpath = check_if_running( log_dir, sector )

    # edit wps namelist and get number of domains and temporary files prefix
    # file removing only works with prefix from this run 
    ndoms, prefix = new_wps_namelist( rsector, rday, nday, begin )
    
    # do file housekeeping in case of earlier abort
    clean_wpsdir( rsector, prefix )
    clean_wrfdir( rsector, True )

    # run WRF
    report_start_processing( gfs_dir, rsector, rday_dir )
    run_wps( rsector, rday_dir, nday_dir, gfs_dir )

    # restart? (start where yestday's run left off
    set_restart( sector, restart, rday, begin, ndoms )

    start_wrf( rsector, rday, nday, begin, rday_dir, ndoms )
    run_wrf( wrf_home, rday_dir, wrf_mpi, wrf_jcl, rsector )
    store_output( out_dir, sector, rday, nday, begin, ndoms )

    # post-processing
    clean_up( rsector, prefix, lockpath )

    ostr = 'RUN COMPLETED AT LOCAL TIME: ' + datetime.datetime.now().isoformat()
    eprint( ostr )
