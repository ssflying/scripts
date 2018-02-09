#!/usr/bin/env perl

use warnings;
use strict;
use Data::Dumper;
use Getopt::Long;
use Pod::Usage;

# default required options
my %opt = (
    timeout => 5,
    interface => "eth1",
);

my $tcpdump_bin = "/usr/sbin/tcpdump";

# parse command-lines
my $help = 0;
my $debug = 0;
GetOptions(
    'count|c=s'		=> \$opt{count},
    'timeout|t=s' 	=> \$opt{timeout},
    'interface|i=s' 	=> \$opt{interface},
    'port|p=s@'		=> \$opt{port},
    'outfile|o=s' 	=> \$opt{outfile},
    'read|r=s' 		=> \$opt{dumpfile},
    'help|h|?'		=> \$help,
    'debug|d'		=> \$debug,
) or pod2usage(-msg => "Syntax error.", -verbose => 1);
pod2usage(1) if $help;

### check $EUID, if non-root, using sudo
if($> != 0) {
    $tcpdump_bin = "sudo /usr/sbin/tcpdump";
}

### check exist instance
if(`pgrep -x tcpdump`) {
    print "There is another tcpdump process, may be you should kill it first!\n";
    exit 1;
}

### get self ip
my $ip = &get_iface_addr($opt{interface});

### read mode
if(defined($opt{dumpfile})) {
    my $hosts = read_dump_file($opt{dumpfile});
    print join("\n", @$hosts);
    print "\n";
    exit 0;
}

### Exceptions conditions
## Ports
# eth1:36000/56000 SSHD
# eth1:5000 tcp_proxy
# eth1:389 9922 9966 safety
my @exception_ports = qw( 36000 56000 5000 389 9922 9966 );

### generate tcpdump syntax
my $exception_port_string = join(" ", map { s/^/port /; s/$/ or/; $_ } @exception_ports);
$exception_port_string =~ s/or$//;

my $exclude_syn_string = "tcp[tcpflags] & tcp-syn = 0";

my $dst_ports = join(" ", map { s/^/dst port /; s/$/ or/; $_ } @{$opt{port}});
$dst_ports =~ s/or$//;

my $dump_file = "test_$opt{interface}_$$.dump";

my $tcpdump = "$tcpdump_bin -i $opt{interface} -w $dump_file" . (defined($opt{count}) ? " -c $opt{count}" : "") . 
	      qq( "$dst_ports" and) .
	      qq( "dst host $ip" and) . 
	      qq( "$exclude_syn_string" and) . 
	      qq( "not (icmp or arp)" and) . 
	      qq( "not ($exception_port_string)");

### start tcpdump
print "$tcpdump\n" if $debug;
               
my $secs_to_timeout = $opt{timeout} * 60;

my $pid = fork;
if ($pid > 0){ # parent
    eval{
	local $SIG{ALRM} = sub {kill 2, -$pid; die "TIMEOUT!"};
	alarm $secs_to_timeout;
	waitpid($pid, 0);
	alarm 0;
    };
}
elsif ($pid == 0){ # child
    setpgrp(0,0);
    exec($tcpdump);
    exit(0);
}

my $found_hosts = read_dump_file($dump_file);

if(defined($opt{outfile})) {
    open my $result, ">" , $opt{outfile}	|| die "Can't open $opt{outfile} for write:$!";
    print $result join("\n", @$found_hosts);
    print $result "\n";
    close $result;
    print "\nresult also saved in $opt{outfile}\n";
} else {
    print join("\n", @$found_hosts);
    print "\n";
}

sub get_iface_addr {
    my $iface = shift;
    open my $fh, '-|', "/sbin/ifconfig $iface";
    while(<$fh>) {
	next unless /inet addr:/;
	chomp;
	my @foo = split;
	return substr($foo[1], 5);
    }
    close $fh;
}

sub read_dump_file {
    my $file = shift;

    my %founded_hosts;
    my $read_tcpdump = "tcpdump -nn -r $file";
    -r $file || die "can't read $file:$!";

    open my $fh, "-|" ,  $read_tcpdump	 || die "can't open $read_tcpdump:$!\n";
    while(<$fh>) {
	next unless /$ip/;
	my $use = (split /:/)[2];
	my ($src, $dst) = (split(/ /, $use))[2,4];
	if($src =~ /$ip/) { 
	    ($src, $dst) = ($dst, $src);
	}
	$src =~ s/\.\d+$//;
	$founded_hosts{$src}++;
    }
    return [ sort keys %founded_hosts ];
}

=head1 NAME

	tcpdump_filter_hosts.pl - retrieve hosts touch you reluctantly

=head1 SYNOPSIS

	tcpdump_filter_hosts.pl [OPTIONS]

	tcpdump_filter_hosts.pl -c 50 				# capture 50 packets to retrieve hosts
	tcpdump_filter_hosts.pl -t 60 				# capture 60 minitues to retrieve hosts
	tcpdump_filter_hosts.pl -c 50 -t 60 			# which comes first wins
	tcpdump_filter_hosts.pl -t 60 -o /tmp/result.txt 	# and save result in file instead of STDOUT
	tcpdump_filter_hosts.pl -i eth0 -t 60            	# capture eth0,instead of default eth1
	tcpdump_filter_hosts.pl -r eth1.dump		     	# read file eth1.dump to show hosts

=head1 DESCRIPTION

	tcpdump_filter_hosts.pl first create tcpdump command line options based on your requirements.
	and then fork child process to exec the tcpdump command, until SECS_TIMEOUT, parent process will
        terminate the tcpdump, and tcpdump will also exit if it captures COUNT packets you have specified.

	it exits when either the condition reaches. and then the script will parse the tcpdump result to 
	retrieve the unique IP address that have connections with you.

=head1 OPTIONS

	-c,--count	same as -c in tcpdump;

	-d,--debug	print 'tcpdump command line'

	-i,--interface	capture this interface, instead of default eth1

	-o,--outfile    save STDOUT to outfile

	-r,--read       read tcpdump dump file to show hosts.

	-t,--timeout	after timeout(in minute, default 10 min), tcpdump will stop capturing.

=head1 AUTHOR

	cqs.pub@gmail.com(Alick Chen)

=head1 BUGS

	need document

=head1 SEE ALSO

	tcpdump(8)

=head1 COPYRIGHT

	this program is free software. You may copy or redistribute it under the same terms as Perl itself.
=cut
