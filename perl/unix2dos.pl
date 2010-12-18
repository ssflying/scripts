#! /usr/bin/perl

while (<>) {
  s/\012//;
  print $_ . "\r\n";
}
