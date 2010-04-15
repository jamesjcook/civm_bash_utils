#!/bin/bash
# quck script to commit all with basic comment of dirname update
for file in `ls -d */` 
do 
    echo $file
    svn ci $file --message "$file update"
done