#!/usr/bin/env bash

url=http://isoredirect.centos.org/centos/8/isos/x86_64/CentOS-8.1.1911-x86_64-dvd1.iso

curl --location --progress-bar -O -w "%{http_code}" "$url" >stdout 2> stderr &
pid=$!
http_code=

until [[ $http_code ]]; do
    read -r http_code <stdout
    printf "%s %s %s\n" "$(date +%F_%T)" "INFO" "$(awk 'BEGIN {RS="\r" } END { print }' <stderr)"
    sleep 1
done

wait "$pid"

echo "download finished"
echo "http code is :$http_code"
