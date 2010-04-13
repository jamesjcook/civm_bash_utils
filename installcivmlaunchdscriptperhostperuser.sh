#!/bin/bash
# installcivmlaunchdscriptperuserperhost.sh
# requires sudo access to cp file
# James Cook
# -installs a plist file and loads/starts it for the purpose of udpating them.
# -installs main script by linking /Users/Shared/<civmscriptname> with the current directory
# DO NOT COPY THE PLIST FILE, THERE CAN BE ONLY ONE FILE ENDING IN .plist IN THIS DIRECTORY FOR THE UTILITY SCRIPTS TO WORK
# you may name the file .plistsomething so long as it doesnt end in exactly .plist   , it wont cause any trouble. 
# modify the plist file to point to the script called 
# name the plist approiately, generally, com.civm.<purpose>.<computer>.<user>.[folder.]plist
# modify the plist <label> field to match the filename,

mainscript=`ls -d civm* | grep -v "\~"`
mainscriptdir=${mainscript%.*}
echo ln -shf `pwd` /Users/Shared/$mainscriptdir
ln -shf `pwd` /Users/Shared/$mainscriptdir

file_template=`ls configs/*.plist_template`
newfilename="${file_template%\.computer.*}.`hostname -s`.`whoami`.plist"

if [ -z `ls $newfilename` ] 
then 
    echo Couldnt find ${newfilenam},coping template into ${newfilename}
    echo cp $file_template $newfilename
    cp $file_template $newfilename 
fi

echo plist now $newfilename
# figure out a clever way to change the plist file name to reflect computer/purpose/user  replace computer with hostname -s and user with whoami

#simple script to put plist in place after its renamed properly
echo "Attempting to use editor variable to open $newfilename likley to fail"
$EDITOR $newfilename
if [ "$?" -ge 1 ]
then
    echo failed to open with EDITOR environment variable, using vi
    vi $newfilename
fi
echo copying $newfilename to system
sudo cp $newfilename /Library/LaunchDaemons/.
./lib/restartscheduler.sh