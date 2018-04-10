#!/usr/bin/env bash

BEGIN_DATE="2018-03-08"	# 记账日为准
END_DATE="2018-04-07"   # 记账日为准

# sed returns self-contained awk script, [] to prevent sed line
awk -v begin=$BEGIN_DATE -v end=$END_DATE -f <(sed -e '/[B]EGIN_AWK1/,/[E]ND_AWK1/!d' $0) <(cat "$@" | iconv -f gbk -t utf8 )

exit 
# shell script end here

#BEGIN_AWK1

BEGIN {
	FS="\t"
	OFS="\t"
}

# 跳过列头
$0 !~ /对账标志/ {
	sub(",", "", $4)	# date
	gsub(",", "", $5)	# details
	split($5, a, "\"")
	date = $4
	if (date >= begin && date <= end) {
	        payee = a[1]
		money = a[4]
		day = (substr(date, 9, 2)+0)	# convert to numberic

		# 还的是上期账单
		#if (payee == "掌上生活还款" && day >= 8 && day <= 25) {
		#	next
		#}
		if(money > 0) {
			sum[date] += money
			total += money
		}
		if(money <0 ) {
			payback[date] += money
			payback_total += money
		}
	}
}

END { 
	for (date in sum) 
		printf("%s\t%.2f\n", date, sum[date])
	
	printf("消费合计: %.2f\n", total)
	for (date in payback)
		printf("%s\t%.2f\n", date, payback[date])
	printf("还款合计：%.2f\n", payback_total)
}

#END_AWK1
