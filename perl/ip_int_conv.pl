#!/usr/bin/perl

use Socket;

my ($ip, $mask) = @ARGV;
if ($ip =~ /\./) {
    print "IP=$ip\n";
    print "IP_bin=" . ipmask_dec2bin($ip) . "\n";
    print "mask=$mask\n";
    print "mask_bin=" . ipmask_dec2bin($mask) . "\n";
    my $network= bin_ipmask(ip2bin($ip) & ip2bin($mask));
    print "network=$network";
}

sub bin_ipmask {
    return inet_ntoa(pack("N", unpack("N", pack("B32", shift))));
}
sub dec2bin {
    substr( unpack( "B32", pack( "N", shift)), -8)
}

sub bin2dec {
    unpack("N", pack("B32", substr("0" x 32, shift, -8)));
}

sub ipmask_dec2bin {
    my $prefix = "";
    my $result;

    map {
	$result .= $prefix . &dec2bin($_); 
	$prefix = ".";
    } split (/\./, shift);
    return $result;
}

sub ipmask_bin2dec {
    my $prefix = "";
    my $result;

    map {
	$result .= $prefix . &bin2dec($_); 
	$prefix = ".";
    } split (/\./, shift);
    return $result;
}


sub ip2bin {
    return unpack 'B32', inet_aton(shift);
}

sub bin2ip {
    return inet_ntoa( pack 'N', shift );
}

