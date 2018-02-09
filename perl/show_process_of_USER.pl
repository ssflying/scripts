#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use File::Basename;
use File::Spec;

my $self_name = basename($0);
my $self_short_name = substr($self_name, 0, 15);

my @exception_cmds = qw(bash ps sort sshd sh perl);
push @exception_cmds, $self_short_name;
my %exception_cmds = map { $_ => 1 } @exception_cmds;

my %programs;

#open my $netstat_result, '-|', 'netstat -tnlup 2>/dev/null'
#    or die "can't open pipe:$!\n";
#while(<$netstat_result>) {
#    if(/LISTEN\s+\d/) {	# it is a server who's listening
#	chomp;
#	s/(:|\/)/ /g;	# convert delimiter to space
#	my ($port, $pid) = (split())[4,8];	# get port and pid
#	if($pid =~ /\d+/) {
#	    my $comm;
#	    chomp($comm =`ps h -p $pid -o comm`);
#	    $programs{$comm}->{port} = $port;
#	}
#    }
#}
#close $netstat_result;

open my $ps_result, '-|', 'ps h x -o pid,comm,lstart | sort -k 2 -u'
    or die "can't open pipe:$!\n";

while(<$ps_result>) {
    chomp;
    my ($pid, $comm, @lstart) = split();
    next if exists $exception_cmds{$comm};
    my ($start_time, $count, $start_path);
    chomp($start_time = `date -d "@lstart" +"%Y-%m-%d_%H:%M"`);
    chomp($count =  `pgrep -x $comm | wc -l`);
    $start_path=&show_pid_path($pid);
    $programs{$comm}->{start_time} = $start_time;
    $programs{$comm}->{count} = $count;
    $programs{$comm}->{start_path} = $start_path;
}
close $ps_result;

sub show_pid_path {
    my $pid = shift;
    my $path = dirname(File::Spec->rel2abs(readlink("/proc/$pid/exe")));
    return $path ? $path : "NULL";
}

sub show_result_in_tab {
    my $programs = shift;
    # Header
    printf "%-20s%-10s%-20s%-10s%-20s\n", "Name", "Count", "StartTime", "Port", "StartPath";
    foreach my $comm (keys %{$programs}) {
	my $port = exists $programs{$comm}->{port} ? $programs{$comm}->{port} : "null";
	printf "%-20s%-10s%-20s%-10s%-20s\n", $comm, $programs{$comm}->{count}, $programs{$comm}->{start_time}, $port, $programs{$comm}->{start_path};
    }
}

sub show_result_in_monitor_proc_conf {
    my $programs = shift;
    foreach my $comm (keys %{$programs}) {
	my $port = exists $programs{$comm}->{port} ? $programs{$comm}->{port} : "null";
	printf "%s||%s|ne|echo ...|eth1|%s\n", $comm, $programs{$comm}->{count}, $port;
    }
}
show_result_in_tab(\%programs);
#show_result_in_monitor_proc_conf(\%programs);
