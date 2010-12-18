#!/usr/bin/perl 
use ExtUtils::Installed;
my ($inst) = ExtUtils::Installed->new();
my (@modules) = $inst->modules();
foreach $module (@modules) {
    my $ver = $inst->version($module);
    printf "%-12s -- %s\n", $module, $ver;
}
