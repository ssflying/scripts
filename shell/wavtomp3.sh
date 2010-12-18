#!/bin/bash

#Get the filenames
cuefile=$1
wavfile=$2

#Other variables
tracks=$(cueprint -d '%N' "$cuefile")

#Get the filenames into an array
count=1
while [ $count -le $tracks ]
do
#Initialize the tracknames array and write a trackname in
        tracknames[$count]=$(cueprint -n$count -t '%p - %T - %02n - %t' "$cuefile")     
#Increment the counter
        count=`expr $count + 1`                                                         
done

#Load up the ID3 tag info into variables for later use
id3count=1
while [ $id3count -le $tracks ]
do
        artist[$id3count]=$(cueprint -n$id3count -t '%p' "$cuefile")
        album[$id3count]=$(cueprint -n$id3count -t '%T' "$cuefile")
        tracknum[$id3count]=$(cueprint -n$id3count -t '%02n' "$cuefile")
        title[$id3count]=$(cueprint -n$id3count -t '%t' "$cuefile")
        echo "Artist: ${artist[$id3count]}"
        echo "Album: ${album[$id3count]}"
        echo "Track No: ${tracknum[$id3count]}"
        echo "Song Title: ${title[$id3count]}"
        id3count=$[$id3count + 1]
done


#Output general file information
cueprint -d '%P - %T\n' "$cuefile"
echo "Total number of tracks: " $tracks

#Split this bitch
cuebreakpoints "$cuefile" | shntool split -n '' -o wav "$wavfile"                      #outputs 001.wav 002.wav, etc

#Convert those waves into mp3s
convertcount=1
while [ $convertcount -le $tracks ]
do
        if [ $convertcount -lt 10 ]                                                     #Got to pad with zeros
        then
                wavenum=0$convertcount
        else
                wavenum=$convertcount
        fi

        #lame --noreplaygain -b 320 "$wavenum.wav" "${tracknames[$convertcount]}.mp3"   #Compress the file and give it the trackname in the array
        lame --noreplaygain -b 320 --ta "${artist[$convertcount]}" --tl "${album[$convertcount]}" --tn "${tracknum[$convertcount]}" --tt "${title[$convertcount]}" "$wavenum.wav" "${tracknames[$convertcount]}.mp3"
        rm ./"$wavenum.wav"                                                             #cleanup
        convertcount=$[$convertcount + 1]

done
