#!/bin/sh
ONLINE_LOG_DIR=/qx/bak/online.log
ONLINE_FILE=online.txt

cat "$ONLINE_LOG_DIR"/*-online.txt | \
awk -F '|' '{stat[$1]+=$2}END{for(item in stat) {print item "|" stat[item]}}' | \
sort 
#> "$ONLINE_LOG_DIR"/"$ONLINE_FILE"



