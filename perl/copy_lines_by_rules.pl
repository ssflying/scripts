#!/usr/bin/env perl
# Desc: copy N-M lines X times and output to STDOUT
# Usage: Edit config in __DATA__ section; 
# ./copy_lines.pl <file >new_file
# somecommand | copy_lines.pl > new_file

use strict;
use warnings;

# Read config from __DATA__ 
my @rule;
while(<DATA>) {
    chomp;
    next if /^#|^$/;
    push @rule, [ split(/[ -]/) ];
}

# do the job
while(<>) {
    chomp;
    for my $rule (@rule) {
	eval { print "$_\n" x $rule->[2] if( $. >= $rule->[0] && $. <= $rule->[1]); };
    }
}

__DATA__
# FORMAT:
# start-end copy_times
1-1 3
2-10 2
