#!/bin/bash
# stopscheduler.sh, stops a launchd plist and removes it from list
# this script stops
# unloads
# It should be run from the install directory
# it cleverly starts it no matter what the name so this little file can be copied to almost any launchd program




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

echo stopping ${file%.*} 
sudo launchctl stop ${file%.*} # this may remove everything after a final period, eg the extensino
echo unloading $file
sudo launchctl unload /Library/LaunchDaemons/$file
