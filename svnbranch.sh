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
tagurlstatus=`echo $initialurl | grep -c tags`
trunkurlstatus=`echo $initialurl | grep -c trunk`
if [  "$tagurlstatus" == 1 ]
then
    echo "this url is in a tag"
    tagurl="${initialurl%/*}"
    projecturlbase="${tagurl%/*}"
else
    projecturlbase="${initialurl%/*}"    
    tagurl="${projecturlbase}/tags"
fi
branchurl="${projecturlbase}/branches"

branchname=$1
if [ -z $branchname ]
then
    echo "Error. you forgot to specify your branch name, make sure its filename safe."
    exit
fi

echo "Getting tags using command: svn list $tagurl"
tags=`svn list $tagurl | cut -d "/" -f 1`
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

if [  "$tagurlstatus" == 1 ]
then
    branchname="${version}_"$branchname
elif [ "$trunkurlstatus" == 1 ]
then
    branchname="trunk_"$lasttag"_"$branchname
fi


if [ -z "$isversioncommited" ]
then
    echo "Found base url: "$projecturlbase
    echo "Tag dir url:    "$tagurl
    echo "Branch dir url: "$branchurl
    echo "Found version:  "$version
    echo "Found tags:     "$tags
    echo "New branch name:"$branchname
#echo Tag array: ${tagarray[*]}
#echo last index is $lastindex
    if [ "$lasttag" != "$version" ] 
    then # prompt for create tag
	echo last tag was: $lasttag which is not $version
	echo "  maybe you should tag this before your branch"
    else
	echo last release version $lasttag upto date with version $version
    fi
    read -n 1 -p "Would you like to branch to: $branchname [y/N]
svn cp $initialurl $branchurl/$branchname
svn switch $branchurl/$branchname     "  OPTION
    echo .
    if [ "$OPTION" == "y" -o "$OPTION" == "Y" ]
    then
	svn cp $initialurl $branchurl/$branchname
	svn switch $branchurl/$branchname
    fi

else 
    echo "Version: $version has not been commited yet, please commit and re run $0"
    exit 1
fi