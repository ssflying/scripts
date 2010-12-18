#!/bin/bash
### Copyright (c) 2010 Remy van Elst
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in
#all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#THE SOFTWARE.
 
VERSION="1.2 beta."
TITLE="SSHdialog $VERSION"
SSH_CONFIG=${SSH_CONFIG:-$HOME/.ssh/config}
SSH_CONFIG_AWK=${SSH_CONFIG_AWK:-$HOME/scripts/awk/ssh_host_ip.awk}
if [ ! -e $SSH_CONFIG ]; then
    echo "SSH config file ($SSH_CONFIG) does not exist, please create it"
    exit 1
fi
if [ ! -e $SSH_CONFIG_AWK ]; then
    echo "SSH host ip regenerate scripts $SSH_CONFIG_AWK does not exist"
    exit 1
fi
HOSTSFILE=`HOSTSFILE 2>/dev/null` || HOSTSFILE=/tmp/sshost.$$
TEMPF=`mktemp -p /tmp/` || exit 1
awk -f $SSH_CONFIG_AWK $SSH_CONFIG > $HOSTSFILE
WIDTH=50
HEIGHT=40
MENUSIZE=6
DIALOG=${DIALOG=dialog}
ALINES=$(awk 'BEGIN{FS="\n";RS=""}END{print NR}' $HOSTSFILE)
LINES=$(awk 'BEGIN{FS="\n";RS="";ORS=" "} {print $1, "\"" $2 "\""}' $HOSTSFILE)
# if [ $ALINES -gt 6 ]; then MENUSIZE=$ALINES; else MENUSIZE=6; fi
MENUSIZE=$ALINES
SMURF="$DIALOG --extra-button --extra-label \"Edit Hosts\" --cancel-label \"Exit\" --ok-label \"Connect\" --menu \"$TITLE\" $HEIGHT $WIDTH $MENUSIZE $LINES"
eval $SMURF 2> $TEMPF
RHOST=$?
KEUZE=`cat $TEMPF`
WHICHSSH=$(awk -v num=$KEUZE 'BEGIN{FS="\n";RS=""} { if(NR == num){print $3}}' $HOSTSFILE)
clear
 
case $RHOST in
  0)
    echo "Connecting $WHICHSSH"
    ssh  $WHICHSSH
    echo "ssh terminated, byebye"
    ;;
  1)
    echo "You selected exit, we will quit"
    exit 0
    ;;
  3)
    vim $SSH_CONFIG
    exec bash $0
    exit 0
    ;;
  255)
    echo "You pressed ESC, we will exit.";
    exit 0
    ;;
esac
 
rm -f $HOSTSFILE $TEMPF
exit 0
