#!/usr/bin/env bash
#===============================================================================
#
#          FILE: auto_tcpdump.sh
# 
#         USAGE: ./auto_tcpdump.sh 
# 
#   DESCRIPTION: run tcpdump until 1. timeout reached 2. captured packets
# 
#       OPTIONS: ---
#  REQUIREMENTS: tcpdump timeout
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Alick Chen, cqs.pub@gmail.com
#  ORGANIZATION: 
#       CREATED: 06/13/2017 16:18
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
set -o monitor			

type tcpdump &>/dev/null || { echo >&2 "require tcpdump command installed."; }

pcap=$HOME/auto_tcpdump.pcap.$$
count=1

# when any child exit, receive CHLD signal, then we kill other all bg process
trap 'p=$(jobs -rp); [[ -n "$p" ]] && sudo kill "$p"' CHLD

# when finished(means wait), we call cleanup func
trap cleanup EXIT

cleanup() {
    if (( $(wc -l < $pcap) > 0 )); then
       	tcpdump -qr $pcap 2>/dev/null
	echo "pcap file is $pcap"
	exit 1
    else
  	rm -f $pcap
  	exit 0
    fi
}

t=$1
shift 
sleep $t &	# timeout child
sudo tcpdump -c $count -w $pcap $@ &>/dev/null & # main child
wait 2>/dev/null
