#!/usr/bin/perl

use Encode;
use LWP::UserAgent;

my $host;
my $port;
my $user;
my $passwd;
my $browser = LWP::UserAgent->new();
$browser->env_proxy();
$browser->credentials("$host:$port", "Nagios Access", "$user", "$passwd");
$browser->agent("Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.2.10) Gecko/20100914 Firefox/3.6.10");

my $url = $ARGV[0];
my $header = $ARGV[1];
my $resp = $browser->get($url);

die "Hmm, error \"", $resp->status_line( ),
"\" when getting $url"  unless $resp->is_success( );
print "$header: ". $resp->header($header). "\n";
print $resp->base(), "\n";
