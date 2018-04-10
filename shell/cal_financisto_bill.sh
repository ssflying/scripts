#!/usr/bin/env bash

BEGIN_DATE="2018-03-07"	# 交易日为准
END_DATE="2018-04-06"   # 交易日为准

# sed returns self-contained awk script, [] to prevent sed line
awk -v begin=$BEGIN_DATE -v end=$END_DATE -f <(sed -e '/[B]EGIN_AWK1/,/[E]ND_AWK1/!d' $0) "$@"

exit 
# shell script end here

#BEGIN_AWK1

BEGIN {
	FS=","
}

# 跳过列头
NR != 1 && $3 ~ /主信用卡/ {
	date=$1
	money=$4
	category=$9
	payee=$10
	if (date >= begin && date <= end) {
		if (money < 0) { # 消费
			total += money
			sum[date] += money
		} else { 	# 返现/退库
			payback += money
			sum_payback[date] += money
		}
		
	}
}

END { 
	n = asorti(sum, tSum)
	for(i=1;i<=n;i++)
		printf("%s\t%.2f\n", tSum[i], sum[tSum[i]])
	
	printf("消费合计: %.2f\n", total)

	n = asorti(sum_payback, tSum_payback)
	for(i=1;i<=n;i++)
		printf("%s\t%.2f\n", tSum_payback[i], sum_payback[tSum_payback[i]])

	printf("还款/退款合计：%.2f\n", payback)
}

#END_AWK1
