#!/bin/bash
# this script
# stops 
# unloads
# loads 
# It should be run from the install directory

STARTDIR=$PWD
#SCRIPTNAME=`basename $STARTDIR`
#. $STARTDIR/lib/functionscivmscript.bash

p#calls component scripts which use sudo to start and stop the schduler.
$STARTDIR/lib/stopscheduler.sh
$STARTDIR/lib/startscheduler.sh

