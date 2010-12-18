#!/bin/bash

url=`sselp`
tmpfile=`mktemp` || exit 1
curl "http://www.flvcd.com/parse.php?kw=$url&flag=" > $tmpfile

if egrep "baidu|youku|youtube" $tmpfile >/dev/null 2>&1; then
    flv=`cat $tmpfile | grep "<U>" | sed 's/<U>//g'`
else
    flv=`cat $tmpfile | egrep -o "http://.*\.flv$"`
fi

rm -f $tmpfile
if  $1 == "d" 
then
    wget $flv -O ~/tmp.flv 
else
    [[ -z $flv ]] || mplayer -cache 1024 $flv && exit
fi
