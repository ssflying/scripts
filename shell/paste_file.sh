#!/bin/bash

if [ $# -eq 1 ] ; then
    file=$1
    url=`wgetpaste -s ca $file | cut -d ' ' -f 7`
    echo "$file -> $url"
elif ! which $1 > /dev/null 2>&1; then
    file=$@
    url=`$@ | wgetpaste -s ca | cut -d ' ' -f 7`
    echo "$file -> $url"
else
    echo "no such file $1"
fi
