#!/bin/sh

PORT=${PORT:-80}
PNAME="${PNAME:-nginx|php5-cgi}"

while getopts p:n: flag
do
    case $flag in
	p) PORT="$OPTARG";;
	n) PNAME="$OPTARG";;
	[?]) echo "wrong arguments";exit 1;;
    esac
done
PID=$(sudo netstat -atulnp | grep LISTEN | grep :$PORT | awk '{print $7}' | awk -F / '{print $1}')
EST=$(sudo netstat -atulnp | grep :$PORT | grep -c EST)
OPEN=$(sudo netstat -atulnp | grep :$PORT | wc -l)

LOAD=$(uptime | sed 's/.*\(load average:.*$\)/\1/g' | sed 's/load average://g')
ONE=$(echo $LOAD | awk -F, '{print $1}')
FIVE=$(echo $LOAD | awk -F, '{print $2}')
FIFTEEN=$(echo $LOAD | awk -F, '{print $3}')

VALUE=$(ps aux | egrep "$PNAME" | grep -v grep | awk '{ cpu += $3; mem += $4} END{ print cpu " " mem }')
CPU=$(echo $VALUE | awk '{print $1}')
MEM=$(echo $VALUE | awk '{print $2}')

echo "========================================"

echo "监控的程序为：$PNAME"
echo "打开$PORT端口的EST连接数为 $EST"
echo "打开$PORT端口的总数为 $OPEN"
echo "$PNAME占用的CPU百分比为 $CPU%"
echo "$PNAME占用的MEM百分比为 $MEM%"
echo "系统平均负载为：1分钟（$ONE)，5分钟（$FIVE）, 15分钟（$FIFTEEN）"

echo "========================================"
