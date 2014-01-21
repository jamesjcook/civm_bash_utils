#!/bin/bash
##############################################################################
# create branch from current dir, and switch to it
##############################################################################

STARTDIR=$PWD
SCRIPTNAME=`basename $STARTDIR`
. $STARTDIR/lib/functionscivmscript.bash

version=`ls $STARTDIR | grep -E "^v[0-9]+(\.?[0-9]+)*"`
# if versions is an array error
initialurl=`svn info | grep URL | cut -d ":" -f 2-`
`echo $initialurl`  | grep -c tags
tagurlstatus=$?
if [ $tagurlstatus ] 
then
    tagdir=`"${initialurl%/*}`
    projecturlbase=`"${tagurl%/*}`
fi
tagdir="${projecturlbase%/*}/tags"
branchdir="${projecturlbase%/*}/branches"

branchname=$1
if [ -z $branchname ]
then
    echo "Error. you forgot to specify your branch name, make sure its filename safe."
    exit
fi


tags=`svn list $tagdir | cut -d "/" -f 1`
#space seperated list
index=0
for tag in $tags
do    
#    echo Adding $tag to tagarray
    tagarray[$index]="$tag"
    ((index=$index+1))
done
lastindex=${#tagarray[*]}

((lastindex=$lastindex-1))
lasttag=${tagarray[$lastindex]}

isversioncomited=`svn status $version`


if [ -z "$isversioncommited" ]
then
    echo Found base url: $projecturlbase
    echo Tag dir url: $tagdir
    echo Branch dir url: $branchdir
    echo Found version: $version
    echo Found tags: $tags
    echo New branch name:$branchname
#echo Tag array: ${tagarray[*]}
#echo last index is $lastindex
    if [ "$lasttag" != "$version" ] 
    then # prompt for create tag
	echo last tag was: $lasttag which is not $version
	read -n 1 -p "Would you like to branch to: $branchname [y/N]
svn cp $initialurl $branchdir/$branchname     "  OPTION
	echo .
	if [ "$OPTION" == "y" -o "$OPTION" == "Y" ]
	then
	    svn cp $projecturlbase $branchdir/$branchname
	fi
    else
	echo last release version $lasttag upto date with version $version
    fi
else 
    echo "Version: $version has not been commited yet, please commit and re run $0"
    exit 1
fi