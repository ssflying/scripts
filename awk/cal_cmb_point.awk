BEGIN { FS="\t"; OFS="\t"; }
NR != 1 {
	sub(",", "", $4)	# date
	gsub(",", "", $5)	# details
	split($5, a, "\"")
	date = $4
	payee = a[1]
	money = a[4]
	sum += money
	if (money > 0 && payee !~ /微信支付/ ) {	# 消费才有积分，微信支付没有
		point = cal_point(money)
	} else {
		point = 0
	}
	total_point += point
	print date, payee, money, point
}

END { 
	printf("\n");
	printf("交易笔数: %d\n", NR-1)
	printf("金额合计: %d\n", sum)
	printf("交易积分合计: %d\n", total_point)
}

function cal_point(m) {
	return int(m / 20)
}
