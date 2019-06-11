#!/bin/sh - 
#===============================================================================
#
#          FILE: get_bond_value.sh
# 
#         USAGE: ./get_bond_value.sh [-v] < bond_id_file
# 
#   DESCRIPTION: 通过新浪财经接口，传入基金代码，返回最新的净值 
# 
#       OPTIONS: -a/--all 显示完整信息
#  REQUIREMENTS: awk,curl
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: cqs.pub@gmail.com
#  ORGANIZATION: 
#       CREATED: 02/10/2019 17:13
#      REVISION: 002
#===============================================================================

set -o nounset                              # Treat unset variables as an error

usage () {
  echo "Usage: $PROGRAM [-a|--all] [--help] [--version] [bondids] [< file]"
}

usage_and_exit () {
  usage
  exit $1
}

version () {
  echo "$PROGRAM version $VERSION"
}

error () {
  echo "$@" 1>&2
  usage_and_exit 1
}

get_bond_info () {
  local api='http://hq.sinajs.cn/list=f_'

  # 接口输出示例：
  # 格式：基金名称,净值,累积净值,昨日净值,日期
  #       var hq_str_f_501054="东方红睿泽三年定开混合,0.8706,0.8706,0.8589,2019-02-01,71.0579";
  for id in "$@"; do
    curl -sL "${api}$id" | 
      awk -v id=$id -v all=$ALL -F'[",]' \
        '{
            if(all)
              printf "%10s%8s%8.4f%40s\n", $6, id, $3, $2
            else
              printf "%.4f\n", $3
         }'
    usleep 300
  done
}

PROGRAM=`basename $0`
VERSION=1.0
ALL=0

while [ $# -gt 0 ]; do
  case $1 in
    -a | --all ) ALL=1 ;;
    -h | --help ) usage_and_exit 0 ;;
    -v | --version | -V )
      version
      exit 0
      ;;
    -*)
      error "Unrecognized option: $1"
      ;;
    *)
      break
      ;;
  esac
  shift
done

if [ $# -eq 0 ]; then
  get_bond_info $(< /dev/stdin)
else
  get_bond_info "$@"
fi | iconv -f gbk -t utf8
