package Test::Webstellation;

use warnings;
use strict;
use JSON::XS;
use File::Temp 'tempfile';
use Webstellation::Request;
use LWP::UserAgent;
use HTTP::Request::Common;

use Test::More qw 'no_plan';
use Data::Dumper;

require Exporter;
our @ISA = qw/Exporter/;
our @EXPORT = qw/test/;

my ($fh, $fname) = tempfile('tmpXXXX', DIR => '/tmp');
our $host = 'http://watcher.mine.nu/constellation/';
#our $host = 'http://localhost:8080';

sub wrap {
	my $result;
	my $json = shift;
	$json = encode_json $json if ref($json);
	if($host) {
		#my ($addr, $port) = split /:/, $host;
		my $ua = LWP::UserAgent->new(agent => 'Webstellation test system');
		my $res = $ua->request(POST $host, [ r => $json ]);
		#skip $res->content unless $res->is_success;
		my $content = $res->content;
		chomp $content;
		skip $content unless $res->is_success;
		$result = $res->content;
	}
	else {
		my $r = Webstellation::Request->new($fname);
		$result = $r->dispatch($json);
	}
	return $result;
}

sub test {
	SKIP: {
		my ($data, $key, $ans, $msg, $sub) = @_;
		my $json = wrap $data;
		my $res;
		#print "$json\n";
		eval { $res = decode_json $json };
		if($@) {
			fail 'Invalid JSON';
		}
		else {
			no strict 'refs';
			if(defined $sub) {
				$sub->($res->{$key}, $ans, $msg);
			}
			else {
				is $res->{$key}, $ans, $msg;
			}
		}
	}
}

1;
