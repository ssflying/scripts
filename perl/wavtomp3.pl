#!/usr/bin/perl -w

use strict;
use Encode;

my $wavfile=$ARGV[0];
my $cuefile=$ARGV[1];

my $tracks=`cueprint -d %N "$cuefile"`;

# split wav file.
print "Total number of tracks: $tracks\n";
`cuebreakpoints "$cuefile" | shntool split -n '' -o wav "$wavfile"`;

print "Split successfully\n";

my $count=1;
my (@artist, @album, @tracknum, @title, @tracknames);
sub gb2utf8 {
        encode("utf8", decode("euc-cn", $_[0]));
}
while ($count <= $tracks) {
        $artist[$count]=gb2utf8(`cueprint -n$count -t %p "$cuefile"`);
        $album[$count]=gb2utf8(`cueprint -n$count -t %T "$cuefile"`);
        $tracknum[$count]=gb2utf8(`cueprint -n$count -t %02n "$cuefile"`);
        $title[$count]=gb2utf8(`cueprint -n$count -t %t "$cuefile"`);
        #print "Artist: $artist[$count]\n" if $artist[$count];
        #print "Album: $album[$count]\n" if $album[$count];
        #print "Track No: $tracknum[$count]\n" if $tracknum[$count];
        #print "Title: $title[$count]\n" if $title[$count];
        if ($title[$count]) {
                if ($artist[$count]) {
                        $tracknames[$count]="$artist[$count] - $title[$count]";
                }
                else {
                        $tracknames[$count]="$count.$title[$count]";
                }
        }
        else {
                $tracknames[$count]="$count";
        }
        #print $tracknames[$count];
        my $wavenum=$count < 10 ? "0$count" : $count ;
        `lame --noreplaygain -b 320 --ta "$artist[$count]" --tl "$album[$count]" --tn "$tracknum[$count]" --tt "$title[$count]" "$wavenum.wav" "$tracknames[$count].mp3"`;
        `rm ./"$wavenum.wav"`;
        ++$count;
}
