#!/bin/bash
# uninstallscheduler.sh, uninstall a plist from the system
# this script 
# stops
# unloads
# deletes
# It should be run from the directory of the plist you wish to modify.



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

./stopscheduler.sh   # stops, unloads
echo removing $file
sudo rm /Library/LaunchDaemons/$file 

