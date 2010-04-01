#!/bin/bash
# checkstatus.sh for launchd script 
name=`whoami`
host=`hostname -s`

file=` ls configs/*${host}*${name}*plist `
file=`basename $file`

echo project plist is $file 
echo Project launchctl entry 
sudo launchctl list | grep ${file%\.*} 
echo project launchd control file contents
cat /Library/LaunchDaemons/$file
