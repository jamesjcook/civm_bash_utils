#!/bin/bash
# release making script for generic civmscript by james

# should do a quick check version, followed by a svn export, should it add back to svn?....?


STARTDIR=$PWD
SCRIPTNAME=`basename $STARTDIR`
. $STARTDIR/lib/functionscivmscript.bash

releasedir="/Users/Shared/civmscriptreleases" # reasonable default?
removetrue="Y"

version=`ls $STARTDIR | grep -E "^v[0-9]+(\.?[0-9]+)*"`
# if versions is an array error
svnurl=`svn info | grep URL | cut -d ":" -f 2- | cut -d" " -f 2-`

svnproj=${svnurl%/*}
REPOSURL=${svnproj%/*}
projectname=${svnproj##*/}
tagdir="${svnurl%/*}/tags"
#echo $REPOSURL/$projectname

tags=`svn list $tagdir | cut -d "/" -f 1`
#echo $tags
#space seperated list
index=0

echo "
$REPOSURL
$projectname
tags
$version"

#exit 
./lib/checktrunkvstags.sh  # make sure release is current.
if [ $? -eq "0" ] 
then
    if [ ! -d "${releasedir}/${projectname}_${version}" -a ! -e "${releasedir}/${projectname}_${version}.tar.gz" ]
    then
	svn export "${REPOSURL}/${projectname}/tags/${version}" "${releasedir}/${projectname}_${version}"
	pushd .
	cd ${releasedir}
	tar --format posix -czf "${projectname}_${version}.tar.gz" "${projectname}_${version}"
	popd 
	read -p "Do you wish to remove ${releasedir}/${projectname}_${version} [Y/n]" -n 1 removetrue
	echo ""
	if [ "$removetrue" = n -o "$removetrue" = N ]
	then
	    echo "WARNING:  ${releasedir}/${projectname}_${version} not removed, "
	    echo "          you will not be able to run this release again until it is delted"
	else
	    rm -rf "${releasedir}/${projectname}_${version}"
	fi
	#scp ${releasedir}/${projectname}_${version}.tar.gz civm:4.ipl@syros:/Volumes/xsyros/Software/civmscriptreleases
    else 
	echo "ERROR:  previously released, or release previously attempted. Delete directory and tar of last attempt.
    ${releasedir}/${projectname}_${version}
    ${releasedir}/${projectname}_${version}.tar.gz"
	exit 1
    fi
    echo "STATUS:  Release tar is ${projectname}_${version}.tar.gz in ${releasedir}/"

#... svn add ${releasedir}/${projectname}_${version}.tar.gz ${REPOSURL}/${projectname}/releases?
else
    echo "checktrunkvstags failed, fix problem and retry."
fi