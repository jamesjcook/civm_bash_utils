#!/bin/bash
# stopscheduler.sh, stops a launchd plist and removes it from list
# this script stops
# unloads
# It should be run from the install directory
# it cleverly starts it no matter what the name so this little file can be copied to almost any launchd program
file=`ls *.plist `

echo stopping ${file%.*} 
sudo launchctl stop ${file%.*} # this may remove everything after a final period, eg the extensino
echo unloading $file
sudo launchctl unload /Library/LaunchDaemons/$file
