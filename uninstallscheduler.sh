#!/bin/bash
# uninstallscheduler.sh, uninstall a plist from the system
# this script 
# stops
# unloads
# deletes
# It should be run from the directory of the script you wish to modify. with a plist in configs/*.plist * can be anything or the host or the host and username see normal rules for those things



###
# STARTDIR Var very imporant, must use these line exactly if using functionscivmscript.bash
###
#FULLPATH="$(cd "${0%/*}" 2>/dev/null; echo "$PWD"/"${0##*/}")"
#STARTDIR=`dirname "$FULLPATH"`
STARTDIR=$PWD
SCRIPTNAME=`basename $STARTDIR`

###
# load common function
###
. $STARTDIR/lib/functionscivmscript.bash


name=`whoami`
host=`hostname -s`

findplist configs  # finds the approiate file
file=$plistfile

file=`basename $file`

$STARTDIR/lib/stopscheduler.sh   # stops, unloads

echo "removing $file (you must be an admin or at least have sudo access)"
sudo rm /Library/LaunchDaemons/$file 

