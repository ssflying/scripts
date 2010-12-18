#!/usr/bin/perl -w
use strict;
use LWP::Simple;

die "Usage: $0 <isbn>\n" unless @ARGV == 1;
my $isbn = $ARGV[0];
die "The ISBN provided($isbn) must be ISBN-10 valid.\n" unless $isbn = &is_isbn_valid($isbn);
#my $html = get("http://www.amazon.com/exec/obidos/ASIN/$isbn")
my $html = get("http://www.amazon.com/gp/product/$isbn")
  or die "Couldn't fetch the page.";

my $rank;
my $title;
my $listprice;
my $price;

if($html =~ m{Amazon Bestsellers Rank:</b>\s*#([\d,]+) in Books}s) {
   $rank = $1;
   $rank =~ tr/,//d;
} else {
    die "regex match failed, check the source html.\n";
}
if($html =~ m{List Price:.*?(\$[\d\.]+)}s) {
    $listprice = $1;
}
if($html =~ m{>Price:.*?(\$[\d\.]+)}s) {
    $price = $1;
}
if($html =~ m{<title>Amazon\.com:\s*(.*?)\(.*</title>}) {
    $title = $1;
}
print "#Done after ", time - $^T ,"s\n";
print "The book \"$title\" ranks $rank on Amazon.com.\n";
print "And the list price is $listprice \n";
print "the sell price is $price \n";

### check ISBN string

sub is_isbn_valid {
    my $a;
    my $b;
    my $isbn = shift;
    my $count = length($isbn);
    return undef if ($count != 10) && ($count != 13);
    if ($count == 13) {
	$isbn = substr($isbn, 3, 10);
    }
    my @isbn = split //, $isbn;

    foreach my $digit (@isbn) {
	$a += $digit;
	$b += $a;
    }
    return ($b % 11 == 0) ? $isbn : undef;
}
