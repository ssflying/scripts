#!/usr/bin/perl

use LWP;
use Encode;
use URI::Escape;
my $browser;
sub do_GET {
  # Parameters: the URL,
  #  and then, optionally, any header lines: (key,value, key,value)
  $browser = LWP::UserAgent->new( ) unless $browser;
  my $resp = $browser->get(@_);
  return ($resp->content, $resp->status_line, $resp->is_success, $resp)
    if wantarray;
  return unless $resp->is_success;
  return $resp->content;
}


foreach my $word (@ARGV) {
    next unless length $word; # sanity-checking
    my $url = 'http://www.baidu.com/s?wd=' .uri_escape($word);
    my ($content, $status, $is_success, $type) = do_GET($url);
    $content = encode('utf-8', decode('cp936', $content));
    if(!$is_success) {
	print "Sorry, failed: $status\n";
    } elsif ($content =~ m/找到相关网页约([\d,]+)篇/) {
	print "$word $1 matches\n";
    } else {
	print "$word is not processable at $url\n";
    }
    sleep 1;
}

