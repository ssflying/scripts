#!/bin/bash
#
# pop-up calendar for dzen
#
# (c) 2007, by Robert Manea
#

TODAY=$(expr `date +'%d'` + 0)
MONTH=`date +'%m'`
YEAR=`date +'%Y'`

(echo '^fg(red)'`date +'%A, %d.%m.%Y %H:%M'`; \
echo; cal | sed -re "s/(^|[ ])($TODAY)($|[ ])/\1^bg(grey70)^fg(#111111)\2^fg()^bg()\3/"; \
[ $MONTH -eq 12 ] && YEAR=`expr $YEAR + 1`; cal `expr \( $MONTH + 1 \) % 12` $YEAR; \
sleep 60) | dzen2 -fn '-*-*-*-*-*-*-28-*-*-*-*-*-iso10646-*' -x 400 -y 60 -w 400 -l 18 -sa c -e 'onstart=uncollapse;button3=exit'
