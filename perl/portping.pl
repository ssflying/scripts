#!/usr/bin/env perl
# Description: check host:port if alive 

use strict;
use Getopt::Long 'HelpMessage';
use IO::Socket;
use Data::Dumper;

# command line options
GetOptions(
    'host=s' => \my $host,
    'port=s' => \(my $port = 36000 ),
    'timeout=i' => \(my $timeout = 3),
    'verbose'	=> \my $verbose,
) or HelpMessage(1);

HelpMessage(1) unless $host;

my (@hosts, @ports);

# parse port
my @ports = get_port_seq($port);

# parse host
my @hosts = get_host_seq($host);

print "Test $host:$port Begin...\n\n";
foreach my $h (@hosts) {
    check_port($h, $_) for @ports;
}
print "\nTestEnd\n";

sub get_port_seq {
    my $port_str = shift;
    my @ports;
    if($port_str =~ /,/) {
	@ports = split(/,/, $port_str);
    } else {
	@ports = ($port_str);
    }
    return @ports;
}

sub get_host_seq {
    my $host = shift;
    return ($host);
}

sub extract_ip {
    my $str = shift;
    my %ips;
    while ($str =~ /(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3});/gs) {
	my $ip = $1;
	$ips{$ip} = $ip;
    }
    return keys %ips;
}

sub check_port {
    my ($host, $port) = @_;

    my $remote = IO::Socket::INET->new(
	Proto    => "tcp",
	PeerAddr => $host,
	PeerPort => $port,
	Timeout  => $timeout,
    );

    if ($remote) {
	print "$host:$port is open\n";
	close $remote;
    }
    else {
	print "$host:$port is closed\n";
    }
}

=head1 NAME

pingport - using tcp to ping hosts with specified port

=head1 SYNOPSIS

    --host,-h		Host to ping(eg. 112,64.237.24 | run.qq.com)
    --port,-p		Port to ping(eg. 8801 | 8801,8802)
    --timeout,-t	Timeout for TCP connect

=head1 VERSION

0.01

=cut
