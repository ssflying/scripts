#!/usr/bin/env bash

# 没有积分的商户名规则
rules=(
微信支付
（特约）京东支付
)

# sed returns self-contained awk script, [] to prevent sed line
gawk -f <(sed -e '/[B]EGIN_AWK1/,/[E]ND_AWK1/!d' $0) <(printf "%s\n" "${rules[@]}") <(iconv -f gbk -t utf8 $1)

exit 
# shell script end here

#BEGIN_AWK1

BEGIN {
	FS="\t"
	OFS="\t"
}

FNR == NR {
	rule[$0]++
	next
}

NR != 1 {
	sub(",", "", $4)	# date
	gsub(",", "", $5)	# details
	split($5, a, "\"")
	date = $4
	payee = a[1]
	money = a[4]
	sum += money

	# 检查消费商户名是否在规则列表中
	flag=0
	for (r in rule) {
		if(payee ~ r) {
			flag=1
			break
		}
	}

	if (money > 0 && flag == 0 ) {	# 不在rule中的payee才有积分
		point = cal_point(money)
	} else {
		point = 0
	}
	total_point += point
	print date, payee, money, point
}

END { 
	printf("交易笔数: %d\n", FNR-1)
	printf("金额合计: %.2f\n", sum)
	printf("交易积分合计: %d\n", total_point)
}

function cal_point(m) {
	return int(m / 20)
}
#END_AWK1
