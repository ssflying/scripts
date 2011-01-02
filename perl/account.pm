#!/usr/bin/perl
### 提示输入用户信息，并返回hash指针
sub CollectInformation {
    use Term::Prompt;
    use Crypt::PasswdMD5;

    my @fields = qw{login fullname id type password};
    my %record;

    foreach my $field (@fields) {
	if($field eq 'password') {
	    $record{$field} = unix_md5_crypt(
		prompt('p', 'Please enter password: ', '', ''), undef);
	}
	else {
	    $record{$field} = prompt('x', "Please enter $field:", '', '');
	}
    }
    print "\n";
    $record{status} = "to_be_created";
    $record{modified} = time();
    return \%record;
}

### 将CollectInformation收集的信息写入指定的文件
### 用法： AppendAccount <filename> <ref_to_record>
sub AppendAccount {
    use DBM::Deep;
    
    my $filename = shift;
    my $record = shift;

    my $db = DBM::Deep->new($filename);
    $db->{ $record->{login} } = $record;
}

# these variables should really be set in a central configuration file
my $useraddex = "/usr/sbin/useradd"; # useradd路径
my $passwdex = "/bin/passwd"; # passwd路径
my $homeUnixdirs = "/home"; # home根目录路径
my $skeldir = "/etc/skel"; # 用户home下的模板配置文件
my $defshell = "/bin/bash"; # 默认shell

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
    if(!$result) {
	InitUnixPasswd($account, $record) or return 0;
    } else {
	return 0;
    }
}

sub DeleteUnixAccount {
    my ($account,$record) = @_;
    ## construct the command line, using:
    # −r = remove the account's home directory for us
    my @cmd = ($userdelex, "−r", $account);
    print STDERR "Deleting account...";
    my $result = 0xff & system @cmd;
    # the return code is 0 for success, non−0 for failure, so we invert
    return ( ($result) ? 0 : 1 );
}

sub InitUnixPasswd {
    use Expect;
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
	1 : 0);
    # close the process object, waiting up to 15 secs for
    # the process to exit
    $pobj−>soft_close( );
    return $result;
}
1;
