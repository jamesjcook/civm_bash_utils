#!/bin/bash
# checks all the folders in the current directory to se if they need to be re-released
# assumes that the current directory is full of svn projects in the standard style
for folder in `ls -d */` 
do
    echo $folder checking trunk against tags
    cd $folder
    bash lib/checktrunkvstags.sh
    cd ..
done
