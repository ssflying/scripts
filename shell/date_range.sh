#!/bin/bash - 
#===============================================================================
#
#          FILE: date_range.sh
# 
#         USAGE: ./date_range.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 12/01/2019 19:21
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

while read -r d1 d2
do
    t1=$(date -d "$d1 12:00 PM" +%s)
    t2=$(date -d "$d2 12:00 PM" +%s)
    if ((t2 > t1)) # swap times/dates if needed
    then
        temp_t=$t1; temp_d=$d1
        t1=$t2;     d1=$d2
        t2=$temp_t; d2=$temp_d
    fi
    t3=$t1
    days=0
    while ((t3 > t2))
    do
        read -r -u 3 d3 t3 3<<< "$(date -d "$d1 12:00 PM - $days days" '+%m/%d/%Y %s')"
        ((++days))
        echo "$d3"
    done
done

