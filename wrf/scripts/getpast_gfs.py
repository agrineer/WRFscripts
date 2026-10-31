#!/usr/bin/env python3

#  getpast_gfs.py                                                       
#                                                                               
#  Copyright (C) 2016-2026 Scott L. Williams
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

copyright = 'getpast_gfs.py Copyright (c) 2016-2026 Scott L. Williams ' + \
            'released under GNU GPL V3.0'   

import os
import sys
import time
import glob
import string
import datetime

# get locations
wrf_home = os.environ['WRF_HOME']
gfshome = wrf_home + '/gfs_0.25'

# print fuctions to reduce clutter and to flush
def eprint( *args ):
    print( *args, file=sys.stderr, flush=True)

def get_file( date_url, gdate, hour ):

    fname =  'gfs.0p25.' + gdate + hour + '.f000.grib2'
    url =  date_url + fname
    eprint( 'getpast_gfs: getting file: ' + fname )
    
    stat = os.system( 'wget -nv -nc ' + url )
    if stat == 0:
        rename = 'gfs.t' + hour + 'z.pgrb2.0p25.f000'
        eprint( 'getpast_gfs: renaming ' + fname + ' to ' + rename )
        command = 'mv ' + fname + ' ' + rename
        stat = os.system( command )
        if stat != 0:
           eprint( '\ngetpast_gfs: could not rename file: ' + fname + '  ... exiting' )
           sys.exit( 0 )
    else:
        eprint( '\ngetpast_gfs: could not retrieve file: ' + fname + ' ... exiting' )
        sys.exit( 0 )
        
def get_analysis_data( gdate ):

    eprint( 'getpast_gfs: getting data for rundate', gdate )

    # parse date string for year
    yr = gdate[:4]
    base_url = 'https://osdf-director.osg-htc.org/ncar/gdex/d084001/'
    date_url = base_url + yr + '/' + gdate + '/'

    get_file( date_url, gdate, '00' )
    get_file( date_url, gdate, '06' )
    get_file( date_url, gdate, '12' )
    get_file( date_url, gdate, '18' )
    
    # remove wget log files
    wget_log = glob.glob( 'wget*' )
    for f in wget_log:
        os.system( 'rm -f ' + f )

########################################################
# main

# right number of arguments?
ac = len( sys.argv )
if ac != 2:
    
    eprint( 'getpast_gfs: must have year argument: eg. getpast_gfs.py 20250101 ... exiting' )
    sys.exit( 1 )

# get UTC rundate from command line
rdate = sys.argv[1]
if len( rdate ) != 8:
    eprint( 'getpast_gfs:badly formed rundate:', rdate )
    sys.exit( 1 )

# is rdate a number?
try:
    irdate = int( rdate )
except:
    eprint( 'getdata_gfs: rundate is not a number:', rdate, '... exiting' )
    sys.exit( 1 )

# get rundate's data
os.chdir( gfshome )
if not os.path.exists( rdate ):
    os.mkdir( rdate )

os.chdir( rdate )
get_analysis_data( str(rdate) )


























