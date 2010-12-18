#!/usr/bin/perl -w
# formpairs.pl - extract names and values from HTTP requests

use strict;
my $data;
if(! $ENV{'REQUEST_METHOD'}) { # not run as a CGI
  die "Usage: $0 \"url\"\n" unless $ARGV[0];
  $data = $ARGV[0];
  $data = $1 if $data =~ s/^\w+\:.*?\?(.+)//;
  print "Data from that URL:\n(\n";
} elsif($ENV{'REQUEST_METHOD'} eq 'POST') {
  read(STDIN, $data, $ENV{'CONTENT_LENGTH'});
  print "Content-type: text/plain\n\nPOST data:\n(\n";
} else {
  $data = $ENV{'QUERY_STRING'};
  print "Content-type: text/plain\n\nGET data:\n(\n";
}
for (split '&', $data, -1) {   # Assumes proper URLencoded input
  tr/+/ /;   s/"/\\"/g;   s/=/\" => \"/;   s/%20/ /g;
  s/%/\\x/g;  # so %0d => \x0d
  print "  \"$_\",\n";
}
print ")\n";
