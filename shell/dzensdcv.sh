#!/bin/sh
# simple popup dictionary, (c) 2007 by Robert Manea

LOOKUP=`sselp`

(echo "$LOOKUP"; sdcv -u "Collins Cobuild English Dictionary" --utf8-output "$LOOKUP") | \
dzen2 -l 8 -p -w 550 -bg darkblue -fg grey75 -x 300 -y 300 \
-fn '-*-dejavu sans-*-*-*-*-14-*-*-*-*-*-iso8859' \
-e 'onstart=scrollhome,uncollapse;button4=scrollup;button5=scrolldown;button1=exit'
