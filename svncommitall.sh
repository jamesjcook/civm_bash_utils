#!/bin/bash
# quck script to commit all with basic comment of dirname update
# asusmes that all directories in the current folder are svn directories and could use comiting. 
# svn will ignore directories which dont need comits.
for file in `ls -d */` 
do 
    echo $file
    svn ci $file --message "$file update"
done