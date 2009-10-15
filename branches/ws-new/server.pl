#!/usr/bin/perl -w

use warnings;
use strict;

use HTTP::Daemon;
use HTTP::Status;
use HTTP::Headers;
use HTTP::Response;
use Webstellation::Request;
use Data::Dumper;
use URI::Escape;

my %conf;
if(open FH, 'server.conf') {
	undef $/;
	for(grep {!/\s*^#/} split /\n/, <FH>) {
		/(.*?)=(.*)/;
		$conf{$1} = $2;
	}
	close FH;
}
else {
	$conf{'port'} = '4440';
	$conf{'db'} = 'data.db';
	$conf{'log'} = 'server.log';
	warn "Failed to read server.conf: $!\nUsing defaults\n";
}

my $g = Webstellation::Request->new($conf{'db'});
print "Starting server...\n";
my $d = HTTP::Daemon->new(LocalPort => $conf{'port'}, Reuse => 1) or die $!;
print "Listening on port $conf{'port'}\n";

while(my $c = $d->accept) {
	#my $pid;
	#if($pid = fork) {
	#	$c->close;
	#	next;
	#}
	#defined($pid) or die "Failed to fork: $!\n";

	my $r = $c->get_request;
	# client request
	unless($r->method eq 'POST') {
		$r->uri('/index.html') if($r->uri eq '/');
		$c->send_file('client'.$r->uri);
		$c->close;
		next;
	}

	$c->send_error(RC_FORBIDDEN) unless $r->uri->path eq '/';

	$r->content =~ /r=(.*)/;
	unless(defined $1) {
		warn "Request variable is missing\n";
		next;
	}
	my $json = uri_unescape $1;
	#print "$json\n";
	print  "-> $1\n";
	print "$json\n\n";
	$c->send_response(HTTP::Response->new(200, status_message(200),
		   HTTP::Headers->new(Content_Type => 'text/plain'), $g->dispatch($json)));
	$c->close;
	#exit;
}
