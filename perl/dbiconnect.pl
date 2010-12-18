#!/usr/bin/perl

# PERL MODULES WE WILL BE USING
use warnings;
use DBI;
use DBD::mysql;

$dsn=$ARGV[0];
$user=$ARGV[1];
$pw=$ARGV[2];

#$dsn = "dbi:mysql:mysql:127.0.0.1:3306";
# CONFIG VARIABLES
#$platform = "mysql";
#$database = "qxworld";
#$host = "124.172.232.157";
#$port = "53306";
#$user = "root";
#$pw = "alickhummy";

#DATA SOURCE NAME
#$dsn = "dbi:mysql:$database:$host:$port";


# PERL DBI CONNECT
$DBIconnect = DBI->connect($dsn, $user, $pw);

if ( $DBIconnect ) {
    if ( ! $DBIconnect->errstr ) {
	exit 0;
    }
}

exit 1;
