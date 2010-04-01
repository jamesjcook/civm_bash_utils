#!/bin/bash
# startlaunchdscript, starts a launchd plist in the current directory
# this script stops
# unloads
# loads 
# starts the launchd controlled script. This means it reinstalls it and runs it once.
# It should be run from the install directory
# it cleverly starts it no matter what the name so this little file can be copied to almost any launchd program


name=`whoami`
host=`hostname -s`

file=` ls configs/*${host}*${name}*plist `
file=`basename $file`

#Examples( sort of)
echo starting ${file%.*}
sudo launchctl start ${file%.*} # this may remove everything after a final period, eg the extension