#!/bin/bash
# installcivmlaunchdscript.txt
# James Cook
# -installs a plist file and loads/starts it for the purpose of udpating them.
# -installs main script by linking /Users/Shared/<civmscriptname> with the current directory
# DO NOT COPY THE PLIST FILE, THERE CAN BE ONLY ONE FILE ENDING IN .plist IN THIS DIRECTORY FOR THE UTILITY SCRIPTS TO WORK
# you may name the file .plistsomething so long as it doesnt end in exactly .plist   , it wont cause any trouble. 
# modify the plist file to point to the script called 
# name the plist approiately, generally, com.civm.<purpose>.<computer>.<user>.[folder.]plist
# modify the plist <label> field to match the filename,
name=`whoami`
host=`hostname -s`

file=`ls configs/*${host}*${name}*plist`
file=`basename $file`

mainscript=`ls -d civm* | grep -v"~"`
mainscriptdir=${mainscript%.*}

echo ln -shf `pwd` /Users/Shared/$mainscriptdir
ln -shf `pwd` /Users/Shared/$mainscriptdir
#simple script to put plist in place after its renamed properly

./lib/installscheduler.sh