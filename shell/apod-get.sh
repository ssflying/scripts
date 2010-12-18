#!/bin/bash
# get the latest pic from APOD(http://apod.nasa.gov/apod/astropix.html)

dir=$HOME/pic/apod
# 若有指定参数，则下载指定天的pic, 否则下载当天的。
# format: 2008年1月1日则:apod.sh 080101
if [ $# -eq 1 ] 
then
        date1=$1
        date2=`date -d $1 +%y%m`
else
        date1=`/bin/date +%y%m%d`
        date2=`/bin/date +%y%m`
fi
html=/tmp/apod.html
img_url=http://antwrp.gsfc.nasa.gov/apod/image/$date2

cd $dir

# get the html file
wget --no-proxy http://antwrp.gsfc.nasa.gov/apod/ap$date1.html -O $html 

# get the pic file
img_name=`grep -m 1 jpg $html | awk -F \" '{print $2}' | awk -F / '{print $NF}'`
wget -c --no-proxy "$img_url/$img_name" -O ${date1}_$img_name

# get description
from=`grep -n "Explanation:" $html | awk -F : '{print $1}'`
to=`grep -n "<p> <center>" $html | awk -F : '{print $1}'`
from=$((from+1))
to=$((to-1))
sed -n "$from,${to}p" $html | sed -e :a -e 's/<[^>]*>//g;/</N;//ba' | awk '{printf "%s", $0}' > ${date1}_${img_name%.*}.dsc

# clean tmp file
rm -f $html
