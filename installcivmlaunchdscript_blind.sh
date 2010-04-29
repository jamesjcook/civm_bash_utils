#!/bin/bash
# installcivmlaunchdscript_blind.txt
# James Cook
# -installs a plist file and loads/starts it for the purpose of udpating them.
# -installs main script by linking /Users/Shared/<civmscriptname> with the current directory
# DO NOT COPY THE PLIST FILE, THERE CAN BE ONLY ONE FILE ENDING IN .plist IN THIS DIRECTORY FOR THE UTILITY SCRIPTS TO WORK
# you may name the file .plistsomething so long as it doesnt end in exactly .plist   , it wont cause any trouble. 
# modify the plist file to point to the script called 
# name the plist approiately, generally, com.civm.<purpose>.<computer>.<user>.[folder.]plist
# modify the plist <label> field to match the filename,
###
# STARTDIR Var very imporant, must use these line exactly if using functionscivmscript.bash
###
#FULLPATH="$(cd "${0%/*}" 2>/dev/null; echo "$PWD"/"${0##*/}")"
#STARTDIR=`dirname "$FULLPATH"`
STARTDIR=$PWD

###
# load common function
###
. $STARTDIR/lib/functionscivmscript.bash


name=`whoami`
host=`hostname -s`

findplist configs  # finds the approiate file
file=$plistfile

file=`basename $file`

mainscript=`ls -d civm* | grep -v"~"`

echo ln -shf `pwd` /Users/Shared/$mainscript
#simple script to put plist in place after its renamed properly

# check if user is part of admin group, or root, 
sudo cp $file /Library/LaunchDaemons/.
#else say failed. must be an admin
$STARTDIR/lib/installscheduler.sh