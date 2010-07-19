#!/bin/bash
##############################################################################
# fetch remote versions, 
# Utility script to get remote configs and check them against the local 
# copies to see if users have updated their configs
##############################################################################
#FULLPATH="$(cd "${0%/*}" 2>/dev/null; echo "$PWD"/"${0##*/}")"
#STARTDIR=`dirname "$FULLPATH"`

STARTDIR=$PWD
SCRIPTNAME=`basename $STARTDIR`
. $STARTDIR/lib/functionscivmscript.bash

whathosts  # sets $distributionlist

# if distirbutionlist is not null
if [ -z "$distributionlist" ]
then
    echo $STARTDIR
    echo $SCRIPTNAME
    for host in $distributionlist
    do 
	echo Checking script $SCRIPTNAME version on $host 
	mkdir -p /tmp/$SCRIPTNAME/${host}/
	scp -o "ConnectTimeout=1" -r root@$host:$STARTDIR/v* /tmp/$SCRIPTNAME/${host}/ &> /dev/null
	echo `ls /tmp/$SCRIPTNAME/$host/v* ` `ls $STARTDIR/v*`
    done
fi
