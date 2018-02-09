#!/usr/bin/env perl
# Desc: extract multiple unique ipv4 address 
# Author: cqs.pub@gmail.com

use strict;
use warnings;

my %ips;

# process line by line:
while(<>) {
	# each time we find an IP
	# this regex is designed to be all on one line.
    	while (/(?!0+\.0+\.0+\.0+$)(([01]?\d\d?|2[0-4]\d|25[0-5])\.([01]?\d\d?|2[0-4]\d|25[0-5])\.([01]?\d\d?|2[0-4]\d|25[0-5])\.([01]?\d\d?|2[0-4]\d|25[0-5]))/g) {

		my $ip = $1;

		# put in a hash to remove duplicates
		$ips{$ip} = $ip;
    }
}

# print result on stdout
print "$_\n" foreach(keys %ips);
