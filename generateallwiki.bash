#!/bin/bash
# quickie to generate all wikientries in current dir

if [ "$#" -ge "1" ] 
then
    list="$1"
else
    list=`ls -d */`
fi

for file in  $list
do
    ./civmgeneratelaunchdscriptswikientries/civmgeneratelaunchdscriptwikientries.pl -sdir $file -tin ./civmgeneratelaunchdscriptswikientries/wikitemplate.txt -wout wikientries/`basename ${file}`wikientry.txt
done