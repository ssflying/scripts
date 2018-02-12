#!/usr/bin/env bash
#===============================================================================
#
#          FILE: auto_split_by_size.sh
# 
#         USAGE: ./auto_split_by_size.sh [line] [size] <file1> <file2> .. <fileN>
# 
#   DESCRIPTION: 根据指定大小分隔文件, 并保留整行, 自动继承原来名字
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: cqs.pub@@gmail.com
#  ORGANIZATION: 
#       CREATED: 07/03/2014 11:33
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

if [[ $# -lt 2 ]]; then
    echo "Usage $0 [size] <file1> <file2> ..."
    exit 1
fi

SIZE=$1

shift 1

do_split() {
    local filename=$(basename $1)
    local extension=${filename##*.}
    local filename=${filename%.*}

    split -a 2 -d -C $SIZE $1 ${filename}-
    for file in ${filename}-[0-9][0-9]
    do
	[[ -e $file ]] &&  mv -v $file ${file}.${extension}
    done
}

for file 
do
    do_split $file
done

