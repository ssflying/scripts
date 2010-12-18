#!/bin/bash


while :; do
	full_capa=$(grep "design capacity" /proc/acpi/battery/BAT0/info | awk '{print $3}')
	remain_capa=$(grep "remaining" /proc/acpi/battery/BAT0/state | awk '{print $3}')
	size_home=$(df -h | grep home | awk '{print $4}')
	size_root=$(df -h | grep sda8 | awk '{print $4}')
	rate=$(echo "scale=2; $remain_capa * 100 / $full_capa" | bc | sed 's/\..*//')
	date=$(date '+%b %d/%a  %H:%M')
	printf '%s %s | %s | %s\n' "Home:$size_home" "/:$size_root" "bat:$rate%" "$date"
	sleep 5
done

# for mutt
#    ml=$(find ~/Mail/{dwm,alt-slackware,mutt}/new -type f | wc -l)
#    inbox=$(find ~/Mail/inbox/new -type f| wc -l)
#    size_home=$(df -h | grep home | awk '{print $4}')
#    size_root=$(df -h | grep hda7 | awk '{print $4}')
#    date=$(date '+%b %d/%a  %H:%M')
#
#    if [ $ml -eq 0 -a $inbox -eq 0 ]; then
#        printf '%s %s | %s\n' "Home:$size_home" "/:$size_root" "$date"
#    elif [ $ml -eq 0 -a $inbox -ne 0 ]; then
#        printf '%s %s | %s | %s\n' "Home:$size_home" "/:$size_root" "inbox: $inbox" "$date"
#    elif [ $ml -ne 0 -a $inbox -eq 0 ]; then
#        printf '%s %s | %s | %s\n' "Home:$size_home" "/:$size_root" "ml: $ml" "$date"
#    elif [ $ml -ne 0 -a $inbox -ne 0 ]; then
#        printf '%s %s | %s %s | %s\n' "Home:$size_home" "/:$size_root" "ml: $ml" "inbox: $inbox" "$date"
#    fi
