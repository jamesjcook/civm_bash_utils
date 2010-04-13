#!/bin/bash
##############################################################################
# fetch remote configs, 
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
echo $STARTDIR
echo $SCRIPTNAME
for host in $distributionlist
do 
    echo Checking configs on $host 
    mkdir -p /tmp/$SCRIPTNAME/${host}/
    scp -o "ConnectTimeout=1" -r root@$host:$STARTDIR/configs/* /tmp/$SCRIPTNAME/${host}/ &> /dev/null
    if diff -yrq /tmp/$SCRIPTNAME/${host}/ $STARTDIR/configs | grep ${host}_ | grep differ  | grep -v "~"
    then
	echo $host has different config 
	for file in `ls /tmp/$SCRIPTNAME/${host}/${host}*` 
	do 
	    file=`basename $file`
	    echo "Moving old file to $file.last"
	    mv $STARTDIR/configs/$file $STARTDIR/configs/$file.last
	    echo "coping new file in place"
	    cp /tmp/${SCRIPTNAME}/${host}/$file ${STARTDIR}/configs/${file}
	done
    fi
done