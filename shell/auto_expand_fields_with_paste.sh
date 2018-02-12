#!/usr/bin/env bash
#===============================================================================
#
#          FILE: auto_expand_fields_with_paste.sh
# 
#         USAGE: ./auto_expand_fields_with_paste.sh  <string to add to line> <file>
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: cqs.pub@gmail.com
#  ORGANIZATION: 
#       CREATED: 07/03/2014 11:56
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

trail_string="$1"
file=$2

line=$(grep -c ^ $file)

paste $file <(perl -e '$s = shift; $l = shift; print "$s\n" x $l;' "$trail_string" "$line")
