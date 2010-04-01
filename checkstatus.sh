#!/bin/bash
# checkstatus.sh for launchd script 








name=`whoami`
host=`hostname -s`

if [`ls configs/*plist | wc -l` == "1"]
then
    file=` ls configs/*plist`  # One config to rule them all.
elif [`ls configs/*${host}*plist | wc -l` == "1"]
    file=`ls configs/*${host}*plist` # each host has a different config
else
    file=`ls configs/*${host}*${name}*plist | wc -l` #each user on a host has a different config
then
fi

file=`basename $file`

echo project plist is $file 
diff -yq --suppress-common-lines configs/$file /Library/LaunchDaemons/$file
echo Project launchctl entry 
sudo launchctl list | grep ${file%\.*} 
echo project launchd control file contents
cat /Library/LaunchDaemons/$file
