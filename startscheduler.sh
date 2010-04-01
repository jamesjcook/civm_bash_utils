#!/bin/bash
# Start scheduler, adds a launchd plist to the list of running services
# this script 
# loads 
# It should be run from the install directory
# it cleverly starts it no matter what the name so this little file can be copied to almost any launchd program




name=`whoami`
host=`hostname -s`

file=` ls configs/*${host}*${name}*plist `
file=`basename $file`

echo loading $file
sudo launchctl load /Library/LaunchDaemons/$file