#!/usr/bin/perl -w

use IO::File;
use XML::Writer;
use XML::Simple;
use Data::Dumper;


sub CollectInformation {
    my @fields = qw{login fullname id type password};
    my %record;

    foreach my $field (@fields) {
	print "Please enter $field: ";
	chomp($record{$field} = <STDIN>);
    }
    $record{status} = "to_be_created";
    return \%record;
}

sub AppendAccountXML {
    # receive the filename
    my $filename = shift;
    # receive a record reference
    my $record = shift;
    # append to that file
    my $fh = new IO::File(">> $filename") or die "Can't append to $filename: $!\n";
    # tell XML::Writer to write to $fh
    my $w = new XML::Writer(OUTPUT => $fh);
    # add declaretion
    #$w->xmlDecl("UTF-8");
    # write the opening tag for an account
    $w->startTag("account");
    # write out all the account info
    foreach my $field (sort keys %{$record}) {
	print $fh "\n\t";
	$w->startTag("$field");
	$w->characters("${$record}{$field}");
	$w->endTag;
    }
    print $fh "\n";
    # write the close tag for <account>
    $w->endTag;
    $w->end;
    $fh->close();
}

sub TransformForWrite {
    my $queueref = shift;
    my $toplevel = scalar each %{$queueref};

    foreach my $user (keys %{$queueref->{$toplevel}}) {
	my %innerhash = 
		map {$_, [$queueref->{$toplevel}{$user}{$_}]}
			keys %{$queueref->{$toplevel}{$user}};
	$innerhash{'login'} = [$user];
	push @outputarray, \%innerhash;
    }

    $ouputref = { $toplevel => \@outputarray };
    return $ouputref;
}

# these variables should really be set in a central configuration file
my $useraddex = "/usr/sbin/useradd"; # location of useradd executable
my $passwdex = "/bin/passwd"; # location of passwd executable
my $homeUnixdirs = "/home"; # home directory root dir
my $skeldir = "/etc/skel"; # prototypical home directory
my $defshell = "/bin/bash"; # default shell

sub CreateUnixAccount{
    my ($account,$record) = @_;
    ## construct the command line, using:
    # −c = comment field
    # −d = home dir
    # −g = group (assume same as user type)
    # −m = create home dir
    # −k = and copy in files from this skeleton dir
    # (could also use −G group, group, group to add to auxiliary groups)
    my @cmd = ($useraddex,
	"−c", $record−>{"fullname"},
	"−d", "$homeUnixdirs/$account",
	"−g", $record−>{"type"},
	"−m",
	"−k", $skeldir,
	"−s", $defshell,
	$account);
    print STDERR "Creating account...";
    my $result = 0xff & system @cmd;
    # the return code is 0 for success, non−0 for failure, so we invert
    if ($result){
	print STDERR "failed.\n";
	return "$useraddex failed";
    }
    else {
	print STDERR "succeeded.\n";
    }
    print STDERR "Changing passwd...";
    unless ($result = &InitUnixPasswd($account,$record−>{"password"})){
	print STDERR "succeeded.\n";
	return "";
    }
    else {
	print STDERR "failed.\n";
	return $result;
    }
}

my $userdelex = "/usr/sbin/userdel"; # location of userdel executable
sub DeleteUnixAccount {
    my ($account,$record) = @_;
    ## construct the command line, using:
    # −r = remove the account's home directory for us
    my @cmd = ($userdelex, "−r", $account);
    print STDERR "Deleting account...";
    my $result = 0xffff & system @cmd;
    # the return code is 0 for success, non−0 for failure, so we invert
    if (!$result){
	print STDERR "succeeded.\n";
	return "";
    }
    else {
	print STDERR "failed.\n";
	return "$userdelex failed";
    }
}

use Expect;
sub InitUnixPasswd {
    my ($account,$passwd) = @_;
    # return a process object
    my $pobj = Expect−>spawn($passwdex, $account);
    die "Unable to spawn $passwdex:$!\n" unless (defined $pobj);
    # do not log to stdout (i.e. be silent)
    $pobj−>log_stdout(0);
    # wait for password & password re−enter prompts,
    # answering appropriately
    $pobj−>expect(10,"New password: ");
    # Linux sometimes prompts before it is ready for input, so we pause
    sleep 1;
    print $pobj "$passwd\r";
    $pobj−>expect(10, "Re−enter new password: ");
    print $pobj "$passwd\r";
    # did it work?
    $result = (defined ($pobj−>expect(10, "successfully changed")) ?
	"" : "password change failed");
    # close the process object, waiting up to 15 secs for
    # the process to exit
    $pobj−>soft_close( );
    return $result;
}

my $addqueue = "account.xml";
my $queuefile = $addqueue;
my $queue;
my $queuecontents;
#&AppendAccountXML($addqueue, &CollectInformation);
open(FILE, $queuefile) or die "Can't open $queuefile:$!\n";
read(FILE, $queuecontents, -s FILE);
close(FILE);
$queue = XMLin("<queue>".$queuecontents."</queue>", KeyAttr=>["login"]);
delete $queue->{account}{"pfc"};
open(OUTFILE, "> test.xml");
print OUTFILE XMLout(TransformForWrite($queue), rootname => "queue");
close(OUTFILE);
#print Data::Dumper->Dump([$queue], ["queue"]);
