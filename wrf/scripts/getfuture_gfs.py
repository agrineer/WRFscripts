#!/usr/bin/env python3

'''
@file getfuture_gfs.py
@author Scott L. Williams.
@package WRFscripts
@brief Retrieves GFS forecast forcing files
@LICENSE
# 
#  getfuture_gfs.py Copyright (C) 2016-2026 Scott L. Williams.
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
'''
copyright = 'getfuture_gfs.py Copyright (c) 2016-2026 Scott L. Williams ' + \
            'released under GNU GPL V3.0'   

import os
import sys
import time
import getopt
import datetime

#gfshome = wrf_home + '/gfs_0.25'
gfshome = '/home/agrineer/gfs_3'
if not os.path.exists( gfshome ):
    os.mkdir( gfshome )

# print fuctions to reduce clutter and to flush
def eprint( *args ):
    print( *args, file=sys.stderr, flush=True)

def get_files( sdate, ndate, day, interval ):

    os.chdir( gfshome )
    if not os.path.exists( ndate ):
        os.mkdir( ndate )
    os.chdir( ndate )
    
    offset = day*24
    
    eprint( 'getfuture_gfs: getting files for date:', ndate )
    nfiles = int(24/interval)  # number of files to get
    for i in range( nfiles ):
        
        stat = os.system( 'wget -nv -nc  https://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.' +
	                   sdate + '/00/atmos/gfs.t00z.pgrb2.0p25.f' + f"{offset:03}" )
        eprint( 'getfuture_gfs: retrieval status=' + str(stat) )
        #eprint( 'https://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.' +
	#                  sdate + '/00/atmos/gfs.t00z.pgrb2.0p25.f' + f"{offset:03}" )
        offset += interval
        
    # remove wget log files
    wget_log = glob.glob( 'wget*' )
    for f in wget_log:
        os.system( 'rm -f ' + f )

########################################################

def usage():
    
    eprint( 'usage: getfuture_gfs.y [-h] -s yyyymmdd -n ndays -i hourly_interval ')
    eprint( '       getfuture_gfs.y [--help] --sdate=YYYYMMDD --ndays=ndays --interval=hourly_interval ')
    eprint( '       where:' )
    eprint( '         yyyymmdd is the start date format' )
    eprint( '         ndays is number of days to retrieve and must be => 1 and <= 15' )
    eprint( '         hourly_interval is the number of hours between files, and must be in (1,2,3,4,6)' )
    sys.exit(2)  

## command line options parsing
##
## input :
##
##     argv : command line argument array
##
## returns:
##
##   sdate  : start date in YYYYMMDD format
##   ndays  : number of days to get
##   interval : hourly interval, must be in (1,2,3,4,6)
## 
def read_args( argv ):
    
    sdate = None   
    ndays = None
    interval = None
    
    try:                                
        opts, args = getopt.getopt( argv,
                                    'hs:n:i:', 
                                    ['help','sdate=','ndays=','interval='])
    except getopt.GetoptError as e:
        eprint( str(e) )
        eprint('unknown command arguments')
        usage()                          
                   
    for opt, arg in opts:

        if opt in ( '-h', '--help' ): 
            usage()                        

        elif opt in ( '-s', '--sdate' ):
            try:
                isdate = int( arg )
            except:
                eprint( 'getfuture_gfs: start date is not a number:', arg, '... exiting.' )
                usage()
                
            if len( arg ) != 8:
                eprint( 'getfuture_gfs: start date must have 8 digits:', arg, '... exiting.' )
                usage()
                
            sdate = arg

        elif opt in ( '-n', '--ndays' ):
            try:
                ndays = int( arg )
            except:
                eprint( 'getfuture_gfs: number of days is not a number:', ndays, '... exiting.' )
                usage()

            if ndays < 1 or ndays > 15:
                eprint( 'getfuture_gfs: number of days must be => 1 and <= 15' )  
                usage()

        elif opt in ( '-i', '--interval' ):
            try:
                interval = int( arg )
            except:
                eprint( 'getfuture_gfs: hourly interval is not a number:', arg, '... exiting.' )
                usage()

            if not interval in (1,2,3,4,6):
                eprint( 'getfuture_gfs: hourly interval must be in (1,2,3,4,6) ... exiting' )
                usage()

    if sdate == None:
        eprint('getfuture_gfs: must have a start date ... exiting.')
        usage()                     

    if ndays == None:
        eprint('getfuture_gfs: must have number of days ... exiting.')
        usage()  
    
    if interval == None:
        eprint('getfuture_gfs: must have hourly interval ... exiting.')
        usage()                     

    return sdate, ndays, interval

# -------------------------------------------------------------------
if __name__ == '__main__':  

    __version__ = '0.1.0'

    sdate, ndays, interval = read_args( sys.argv[1:] )
    eprint( '            version:', __version__    )
    eprint( 'arguments given are:' )
    eprint( '             sdate = ' + sdate )
    eprint( '             ndays = ' + str(ndays) )
    eprint( '          interval = ' + str(interval) )

    # parse date string
    yr = int( sdate[:4] )
    mn = int( sdate[4:6] )
    dy = int( sdate[6:8] )
    start_date = datetime.date( yr,mn,dy ) # create time object
             
    get_files( sdate, sdate, 0, interval )

    for i in range( 1, int(ndays) ):

        # get date as YYYYMMDD
        nextdate = start_date + datetime.timedelta( days = i )
        ndate = nextdate.strftime( '%Y%m%d' )

        get_files( sdate, ndate, i, hourly )
