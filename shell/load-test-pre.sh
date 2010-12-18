#!/bin/bash

date=$(date +%m%d)
hosts="66 98 158 159 160"
orig_log_dir="/qx/app/qxuser-logs"
mod_log_prefix="/qx/app/qxuser-logs-$date"
USER=`whoami`
DB_HOST="124.172.232.157"

db_prepare() {
    local db_update_file
    read -p "从哪个数据库文件中导入？输入日期：" tag 
    db_update_file="/qx/bak/db/update-qxworld-2010$tag.sql.gz"

    ssh -p 51822 $USER@$DB_HOST "gzip -dc $db_update_file | mysql -uroot -pdwqx_mysqlsa qxworld_test"

	ssh -p 51822 $USER@$DB_HOST "mysql -uroot -pdwqx_mysqlsa -e 'delete from Userinfo where length(id) > 1;'"
	ssh -p 51822 $USER@$DB_HOST "mysql -uroot -pdwqx_mysqlsa -e 'delete from Player where length(id) > 1;'"
	ssh -p 51822 $USER@$DB_HOST "mysql -uroot -pdwqx_mysqlsa -e 'INSERT INTO Userinfo SELECT * FROM qxworld.Userinfo;'"
	ssh -p 51822 $USER@$DB_HOST "mysql -uroot -pdwqx_mysqlsa -e 'INSERT INTO Player SELECT * FROM qxworld.Player;'"
}
