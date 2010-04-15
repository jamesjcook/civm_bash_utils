#!/bin/bash
# checks all the folders in the current directory to se if they need to be re-released
for folder in `ls -d */` 
do
    echo $folder checking trunk against tags
    cd $folder
    bash lib/checktrunkvstags.sh
    cd ..
done
