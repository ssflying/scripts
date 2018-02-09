#!/usr/bin/env perl
# Description: convert csv format to HTML code block
# Author: cqs.pub@gmail.com
use strict;
use warnings;
use HTML::Table;

my @info;
my $cols;
while(<>) {
    chomp;
    my @row = split(/\t/);
    $cols = $#row + 1;
    push @info, [ @row ];
}

my $table = HTML::Table->new(
    -cols => $cols,
    -border => 1,
    -padding => 1,
);

for my $row (@info) {
    $table->addRow(@{$row});
}

$table->print;
