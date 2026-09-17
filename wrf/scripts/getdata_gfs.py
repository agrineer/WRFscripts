#!/usr/bin/env python3

#  getdata_gfs.py                                                       
#                                                                               
#  Copyright (C) 2016-2024 Scott L. Williams
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

copyright = 'getdata_gfs.py Copyright (c) 2016-2024 Scott L. Williams ' + \
            'released under GNU GPL V3.0'   

import os
import sys
import time
import glob
import string
import datetime

wrf_home = os.environ['WRF_HOME']
gfshome = wrf_home + '/gfs_0.25'

# print fuctions to reduce clutter and to flush
def eprint( *args ):
    print( *args, file=sys.stderr, flush=True)

def oprint( *args ):
    print( *args, file=sys.stdout, flush=True)

def get_analysis_data( gdate ):

    eprint( gdate )
    # NOTE: on 20240416 NCEP changed the product location and error statements
    
    eprint( 'getting data for rundate', gdate )
    stat = os.system( 'wget -nv -nc  https://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.' +
	              gdate + '/00/atmos/gfs.t00z.pgrb2.0p25.f000' )
    eprint( stat )
    stat = os.system( 'wget -nv -nc  https://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.' +
	              gdate + '/06/atmos/gfs.t06z.pgrb2.0p25.f000' )
    eprint( stat )
    stat = os.system( 'wget -nv -nc  https://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.' +
	              gdate + '/12/atmos/gfs.t12z.pgrb2.0p25.f000' )
    eprint( stat )
    stat = os.system( 'wget -nv -nc  https://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.' +
	              gdate + '/18/atmos/gfs.t18z.pgrb2.0p25.f000' )
    eprint( stat )

    # remove wget log files
    wget_log = glob.glob( 'wget*' )
    for f in wget_log:
        os.system( 'rm -f ' + f )

########################################################
# set up date strings
ac = len( sys.argv )
if ac < 2:
    
    # run with yesterday's UTC data
    #nextdate = datetime.datetime.utcnow() # deprecated
    nextdate = datetime.datetime.now(datetime.UTC)
    ndate = nextdate.strftime( '%Y%m%d' )
    rundate = nextdate - datetime.timedelta( days = 1 )
    rdate = rundate.strftime( '%Y%m%d' )
    
else:
    # get UTC rundate from command line
    rdate = sys.argv[1]
    if len( rdate ) != 8:
        eprint( 'getdata_gfs:badly formed rundate:', rdate )
        sys.exit( 1 )
    try:
        irdate = int( rdate )
    except:
        eprint( 'getdata_gfs: rundate is not a number:', rdate )
        sys.exit( 1 )

    # parse date string
    yr = int( rdate[:4] )
    mn = int( rdate[4:6] )
    dy = int( rdate[6:8] )
    rundate = datetime.date( yr,mn,dy ) # create time object
    
    nextdate = rundate + datetime.timedelta( days = 1 )
    ndate = nextdate.strftime( '%Y%m%d' )
                
# get rundate's data
os.chdir( gfshome )
if not os.path.exists( rdate ):
    os.mkdir( rdate )

os.chdir( rdate )
get_analysis_data( rdate )

# get rundate + 1 data
os.chdir( gfshome )
if not os.path.exists( ndate ):
    os.mkdir( ndate )

os.chdir( ndate )

# get data for next date
get_analysis_data( ndate )


























