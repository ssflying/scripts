#!/usr/bin/env perl
use Text::CSV_XS;
use warnings;
use strict;

my @rows;
my $csv = Text::CSV_XS->new ({ binary => 1, always_quote => 1 }) or
die "Cannot use CSV: ".Text::CSV_XS->error_diag ();
open my $fh, "<:encoding(utf8)", "lastpass.csv" or die "lastpass.csv: $!";
my @header = ("Account", "Login Name", "Password", "Web Site", "Comments");
push @rows, \@header;
while (my $row = $csv->getline ($fh)) {
    next if $. eq 1;	# ignore header
    my @kee_fields = @{$row}[4,1,2,0];
    @{$row} = (@kee_fields, "");
    push @rows, $row;
}
$csv->eof or $csv->error_diag ();
close $fh;

$csv->eol ("\r\n");
open $fh, ">:encoding(utf8)", "keepass.csv" or die "keepass.csv: $!";
$csv->print ($fh, $_) for @rows;
close $fh or die "keepass.csv: $!";
