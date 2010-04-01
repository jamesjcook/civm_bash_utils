#!/bin/bash
# installscheduler.sh, installs a launchd plist into the system launchdaemon and loads it
# this script 
# stops 
# unloads 
# copies 
# loads 
# It should be run from the install directory
# it cleverly starts it no matter what the name so this little file can be copied to almost any launchd program

name=`whoami`
host=`hostname -s`

if [ `ls configs/*plist | wc -l` == "1" ]
then
    file=` ls configs/*plist`  # One config to rule them all.
elif [ `ls configs/*${host}*plist | wc -l` == "1" ]
then
    file=`ls configs/*${host}*plist` # each host has a different config
else
    file=`ls configs/*${host}*${name}*plist | wc -l` #each user on a host has a different config
fi

file=`basename $file`


./stopscheduler.sh # stops and unloads

echo copying $file
# could also be done using ln, i should look into that
sudo cp $file /Library/LaunchDaemons/.

./startscheduler.sh # loads scheduler, as "starting" the scheduler would start the service and that isnt whats wanted here.
