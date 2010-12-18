### convert csv(comma seperate line) to mysql insert sentences
### the csv file format should be:
# userid1,title1,money
# userid2,title2,money
# userid3,title3,money

BEGIN { 
    FS = ","
    OFS = ","
    sq = "'"
    recordtime = "now()"
    type = sq 1 sq
    hasread = sq 0 sq
    sender = sq 10006 sq
    mail_tail = "快到咕噜街的小丑里奇那里去领取吧！\n感谢你的参与，请继续关注《猫头鹰通讯》，更多的奖励等你来拿！\n                                                                猫头鹰通讯编辑部"
    print "use qxworld;"
    print "insert into Mail (type, title, content, sender, receiver, hasRead, recordTime) values"
}
{
    if( NR == 1 ) {
	next
    }
    if( NF != 3 ) {
	print "请检查第" NR "行的错误"
	exit
    }

    if(match($2, /[0-9]+/)) {
	tag = substr($2, RSTART, RLENGTH)
    }
    mail_head = "亲爱的小奇想，\n你在第" tag "期《猫头鹰通讯》上《" $2 "》栏目下的投稿获得奖励：\n"
    receiver = sq$1sq
    title = sq$2sq
    money = sq$3sq
    reward = $3 "奇想贝，"
    content = sq mail_head reward mail_tail sq
    if(NR == nl)
	print "(" type, title, content, sender, receiver, hasread, recordtime");"
    else
	print "(" type, title, content, sender, receiver, hasread, recordtime"),"
}
