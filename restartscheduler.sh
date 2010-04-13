#!/bin/bash
# this script
# stops 
# unloads
# loads 
# It should be run from the install directory

#calls component scripts which use sudo to start and stop the schduler.
./lib/stopscheduler.sh
./lib/startscheduler.sh

