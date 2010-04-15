##############################################################################
# check trunk vs tags
# checks the trunk v* file against the tags
##############################################################################

STARTDIR=$PWD
SCRIPTNAME=`basename $STARTDIR`
. $STARTDIR/lib/functionscivmscript.bash

version=`ls $STARTDIR | grep -E "^v[0-9]+(\.?[0-9]+)*"`
# if versions is an array error
svnurl=`svn info | grep URL | cut -d ":" -f 2-`
tagdir="${svnurl%/*}/tags"
tags=`svn list $tagdir | cut -d "/" -f 1`
#space seperated list
index=0
for tag in $tags
do    
    echo Adding $tag to tagarray
    tagarray[$index]="$tag"
    ((index=$index+1))
done
lastindex=${#tagarray[*]}

((lastindex=$lastindex-1))
lasttag=${tagarray[$lastindex]}


echo Found version: $version
echo Found svn url: $svnurl
echo Tag dir url: $tagdir
echo Found tags: $tags
echo Tag array: ${tagarray[*]}
echo last index is $lastindex
if [ "$lasttag" != "$version" ] 
then # prompt for create tag
echo last tag was: $lasttag which is not $version
fi