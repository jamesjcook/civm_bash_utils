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
mainscript=`ls -d civm* | grep -v"~"`
name=`whoami`
host=`hostname -s`

if [ `ls configs/*plist | wc -l` == "1" ]
then
    file=` ls configs/*plist`  # One config to rule them all.
elif [ `ls configs/*${host}*plist | wc -l` == "1" ]
then
    file=`ls configs/*${host}*plist` # each host has a different config
else
    file=`ls configs/*${host}*${name}*plist | wc -l` #each user on a host has a different config
fi

file=`basename $file`

echo ln -shf `pwd` /Users/Shared/$mainscript
#simple script to put plist in place after its renamed properly

sudo cp $file /Library/LaunchDaemons/.
./installscheduler.sh