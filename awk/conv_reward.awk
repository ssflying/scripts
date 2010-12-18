### convert csv(comma seperate line) to mysql insert sentences
### the csv file format should be:
# userid1,title1,money
# userid2,title2,money
# userid3,title3,money


BEGIN { 
    FS = ","
    OFS = ","
    sq = "'"
    createtime = "now()"
    split("a,b,c,d,e,f,g", tag, ",")
    print "use qxworld;"
    print "insert into Reward (rewardId, playerId, money, description, createTime) values"
}
{
    ++id[$1]
    if( NR == 1 ) {
	next
    }
    if( NF != 3 ) {
	print "请检查第" NR "行的错误"
	exit
    }
    if (match($2, /[0-9]+/)) {
       	rewardid = sq substr($2, RSTART, RLENGTH) 
    }
    if (id[$1] > 1) 
	rewardid = rewardid tag[id[$1]] sq
    else
	rewardid = rewardid sq

    playid=sq$1sq
    money=sq$3sq

    description=sq$2sq
    if(NR == nl)
	print "(" rewardid, playid, money, description, createtime");"
    else
	print "(" rewardid, playid, money, description, createtime")" ","
}
