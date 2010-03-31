#!/bin/bash
# checkstatus.sh for launchd script 

file=`ls *.plist`

echo project plist is $file 
echo Project launchctl entry 
sudo launchctl list | grep ${file%\.*} 
echo project launchd control file contents
cat /Library/LaunchDaemons/$file
