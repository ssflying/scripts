#! /usr/bin/perl -i

while (<>) {
  s/\015\012//;
  print $_ . "\n";
}
