#!/bin/bash
# release making script for generic civmscript by james

# should do a quick check version, followed by a svn export, should it add back to svn?....?


./checktrunkvstags.sh  # make sure release is current.
if [ $? -eq "0" ] 
then
    svn export ${REPOSURL}/${project}/tags/${version} ${project}_${version}
    tar -xzf ${project}_${version} ${project}_${version}.tar.gz 
#... svn add ${project}_${version}.tar.gz ${REPOSURL}/${project}/releases?
else
    echo "checktrunkvstags failed, fix problem and retry."
fi