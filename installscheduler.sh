#!/bin/bash
# installscheduler.sh, installs a launchd plist into the system launchdaemon and loads it
# this script 
# stops 
# unloads 
# copies 
# loads 
# It should be run from the install directory
# it cleverly starts it no matter what the name so this little file can be copied to almost any launchd program

###
# STARTDIR Var very imporant, must use these line exactly if using functionscivmscript.bash
###
FULLPATH="$(cd "${0%/*}" 2>/dev/null; echo "$PWD"/"${0##*/}")"
STARTDIR=`dirname "$FULLPATH"`

###
# load common function
###
. $STARTDIR/lib/functionscivmscript.bash


name=`whoami`
host=`hostname -s`

findplist   # finds the approiate file
file=$plistfile

file=`basename $file`

$STARTDIR/lib/stopscheduler.sh # stops and unloads

echo copying $file (you must be an admin or at least have sudo access)
# could also be done using ln, i should look into that
# check if user is part of admin group, or root, 
sudo cp $file /Library/LaunchDaemons/.
#else say failed. must be an admin

$STARTDIR/lib/startscheduler.sh # loads scheduler, as "starting" the scheduler would start the service and that isnt whats wanted here.
