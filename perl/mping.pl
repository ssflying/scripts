#!/usr/bin/env perl
use Net::Ping;

# fill this array with your ips
my @ips = qw(125.39.240.113 123.58.180.8);
my @ips_up;

use constant { TIMEOUT => 1000, PORT => 80 };
my $p = Net::Ping->new( "syn", TIMEOUT() / 1000 );
$p->{port_num} = PORT;

$p->ping($_) for (@ips);
while ( my ( $host, $rtt, $ip ) = $p->ack ) {
  push @ips_up, $ip;
}

local $" = "\n";
print "@ips_up\n";
