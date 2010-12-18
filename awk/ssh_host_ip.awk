#!/usr/bin/awk -f

BEGIN { FS = "\n"; RS = "";}
{
    IGNORECASE = 1
    if ( $1 ~ /^Host [^\*]/  ) {
	nickname = substr($1, 6)
	for(i=2; i<=NF; ++i) {
	    #if( match($i, /^[[:blank:]]*Port /) ) 
	    if( match($i, /^[[:blank:]]*Port /) )  
		port = substr($i, RSTART + RLENGTH)
	    if( match($i, /^[[:blank:]]*HostName /) )
		ip = substr($i, RSTART + RLENGTH)
	    if( match($i, /^[[:blank:]]*User /) )
		user = substr($i, RSTART + RLENGTH)
	}
	print ++id
	print nickname
	print user "@" ip " -p " port "\n"
    }
    next
}
