#!/bin/bash
# stopscheduler.sh, stops a launchd plist and removes it from list
# this script stops
# unloads
# It should be run from the install directory
# it cleverly starts it no matter what the name so this little file can be copied to almost any launchd program

###
# STARTDIR Var very imporant, must use these line exactly if using functionscivmscript.bash
###
#FULLPATH="$(cd "${0%/*}" 2>/dev/null; echo "$PWD"/"${0##*/}")"
#STARTDIR=`dirname "$FULLPATH"`
STARTDIR=$PWD

echo $0 STARTDIR $STARTDIR

###
# load common function
###
. $STARTDIR/lib/functionscivmscript.bash


name=`whoami`
host=`hostname -s`

findplist configs  # finds the approiate file
file=$plistfile

file=`basename $file`

echo stopping ${file%.*}
sudo launchctl stop ${file%.*} # this may remove everything after a final period, eg the extensino
echo unloading $file
sudo launchctl unload /Library/LaunchDaemons/$file
