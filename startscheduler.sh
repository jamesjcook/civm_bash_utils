#!/bin/bash
# Start scheduler, adds a launchd plist to the list of running services
# this script 
# loads 
# It should be run from the install directory
# it cleverly starts it no matter what the name so this little file can be copied to almost any launchd program




name=`whoami`
host=`hostname -s`

if [`ls configs/*plist | wc -l` == "1"]
then
    file=` ls configs/*plist`  # One config to rule them all.
elif [`ls configs/*${host}*plist | wc -l` == "1"]
then
    file=`ls configs/*${host}*plist` # each host has a different config
else
    file=`ls configs/*${host}*${name}*plist | wc -l` #each user on a host has a different config
then
fi

file=`basename $file`

echo loading $file
sudo launchctl load /Library/LaunchDaemons/$file