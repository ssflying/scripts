#!/bin/sh

user=pfc
url="http://imagebin.org/index.php"
png="$HOME/screenshot-`date -I`.png"
gap=3
sleep $gap
import -window root $png
curl  -F "nickname=$user" -F "image=@$png;type=image/png"  -F "disclaimer_agree=Y" -F "Submit=Submit" -F "mode=add" "$url"
if [ $? -eq 0 ]; then
    id=$(curl -s "$url" | grep "$user" | head -n 1 | cut -d \" -f2)
    echo "http://imagebin.org/$id"
else
    echo "post failed"
fi
