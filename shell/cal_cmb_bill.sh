#!/usr/bin/env bash

BEGIN_DATE="2019-11-07"	# 交易日为准
END_DATE="2019-12-01"   # 交易日为准

# 输入的csv格式要求：
# 第一列为：2019-11-01 这样日期格式
# 编码为UTF-8,换行为unix
# 获取步骤：
#	1. 招行大众银行网页版下载未出账单的userdata.csv文件
#	2. sed -i 's/\t//g' userdata.csv 去掉多余的制表符
#	3. excel打开该文件, 调整第一列日期格式为2019-11-01，然后另存为制表符分隔的txt文件: userdata.txt
#	4. dos2unix userdata.txt; iconf -f gbk -t utf8 < userdata.txt > userdata.csv

# sed returns self-contained awk script, [] to prevent sed line
awk -v begin=$BEGIN_DATE -v end=$END_DATE -f <(sed -e '/[B]EGIN_AWK1/,/[E]ND_AWK1/!d' $0) "$@"

exit 
# shell script end here

#BEGIN_AWK1

BEGIN {
	FS="\t"
	OFS=","
}

# 跳过列头
NR > 1 {
	date = $1
	if (date >= begin && date <= end) {
	        payee = $3
		gsub("\042", "", $6)
		gsub(",", "", $6)
		money = substr($6,2)

		if (payee ~ /还款/ )	# skip payback
			next

		cnt[date] += 1
		sum[date] += money
		total += money
	}
}

END { 
	for (date in sum) 
		printf("%s,%d,%.2f\n", date, cnt[date], sum[date])

	printf("total,%.2f\n", total)
}

#END_AWK1
