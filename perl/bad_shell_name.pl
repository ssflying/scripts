#!/usr/bin/perl -w

use User::pwent;
use strict;

my $shells = "/etc/shells";
my %okshell;
my $pwent;
open(SHELL, "< $shells") or die "can't not open $shells: $!\n";
while(<SHELL>) {
    chomp;
    $okshell{$_}++;
}
close(SHELL);

while($pwent = getpwent()) {
    warn $pwent->name . " has a bad shell (" . $pwent->shell . ")!\n" 
    unless (exists $okshell{$pwent->shell});
}
endpwent();
    
