#!/bin/bash
# reinstallscheduler.sh, uninstall a plist from the system
# this script 
# uninstalls
# installs
# It should be run from the directory of the script you wish to modify. with a plist in configs/*.plist * can be anything or the host or the host and username see normal rules for those things




###
# STARTDIR Var very imporant, must use these line exactly if using functionscivmscript.bash
###
#FULLPATH="$(cd "${0%/*}" 2>/dev/null; echo "$PWD"/"${0##*/}")"
#STARTDIR=`dirname "$FULLPATH"`
STARTDIR=$PWD
SCRIPTNAME=`basename $STARTDIR`

echo "Uninstalling"
$STARTDIR/lib/uninstallscheduler.sh   # stops, unloads, removes
echo "Installing"
$STARTDIR/lib/installscheduler.sh   # cp, load, start, 

