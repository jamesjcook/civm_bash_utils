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

#Examples( sort of)
echo starting ${file%.*}
sudo launchctl start ${file%.*} # this may remove everything after a final period, eg the extension