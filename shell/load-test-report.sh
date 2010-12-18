#!/bin/sh

# 报告文件的路径
logfile="/tmp/load-test-`date -I`.csv"
# 设置间隔时间
delay=300
# 设置监控端口（mina端口）
port=81
# 设置用ps aux | grep <>的进程名
pname="qxserver-test"
# mina在线人数日志的统计路径
mina_dir="/qx/app/qxserver-test"
online_log="logs/onlineqty/onlineqty.log"

# 报告抬头
echo "时间,Mina连接数,在线人数日志,CPU占用,Mem占用,带宽占用,负载,压测过程中有无优化,是否正常游戏" > $logfile
# 无限循环，手动Ctrl+c中断
while true
do
    date=$(date +%t)
    pid=$(sudo netstat -atulnp | grep listen | grep :$port | awk '{print $7}' | awk -f / '{print $1}')
    est=$(sudo netstat -atulnp | grep :$port | grep -c EST)

    people=$(tail -n 1 "$mina_dir"/"$online_log" | awk -f'|' '{print $2}')

    value=$(ps aux | egrep "$pname" | egrep -v 'grep|tail' | awk '{ cpu += $3; mem += $4} end{ print cpu " " mem }')
    cpu=$(echo $value | awk '{print $1}')
    mem=$(echo $value | awk '{print $2}')

    bandwidth=$(ifstat -i eth0 1 1 | tail -n 1 | awk '{if ($1 > $2) {print $1} else {print $2}}')

    load=$(uptime | sed 's/.*\(load average:.*$\)/\1/g' | sed 's/load average://g')
    one=$(echo $load | awk -f, '{print $1}')
    #five=$(echo $load | awk -f, '{print $2}')
    #fifteen=$(echo $load | awk -f, '{print $3}')
    echo "$date,$est,$people,$cpu%,$mem%,$bandwidth,$one,无,是" >> $logfile
    sleep $delay
done

