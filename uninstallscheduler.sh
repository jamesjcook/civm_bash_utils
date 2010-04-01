#!/bin/bash
# uninstallscheduler.sh, uninstall a plist from the system
# this script 
# stops
# unloads
# deletes
# It should be run from the directory of the plist you wish to modify.



name=`whoami`
host=`hostname -s`

file=` ls configs/*${host}*${name}*plist `
file=`basename $file`

./stopscheduler.sh   # stops, unloads
echo removing $file
sudo rm /Library/LaunchDaemons/$file 

