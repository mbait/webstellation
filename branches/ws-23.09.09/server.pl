#!/usr/bin/perl -w

use warnings;
use strict;

use HTTP::Daemon;
use HTTP::Status;
use HTTP::Response;
use Webstellation::Request;
use Data::Dumper;

my %conf;
if(open FH, 'server.conf') {
	undef $/;
	for(grep {!/^#/} split /\n/, <FH>) {
		/(.*?)=(.*)/;
		$conf{$1} = $2;
	}
	close FH;
}
else {
	$conf{'port'} = '4440';
	$conf{'dbfile'} = 'data.db';
	warn "$! - using defaults\n";
}

print "Starting game server...\n";
my $g = Webstellation::Request->new($conf{'dbfile'});
print "Starting server...\n";
my $d = HTTP::Daemon->new(LocalPort => $conf{'port'}) or die $!;
print "Server is listening on port $conf{'port'}\n";
while(my $c = $d->accept) {
	my $r = $c->get_request;
	$c->send_error(RC_NOT_IMPLEMENTED) unless $r->method eq 'POST';
	$c->send_error(RC_FORBIDDEN) unless $r->uri->path eq '/';

	$c->send_response(HTTP::Response->new(200, status_message(200),
		   'Content-type' => ' text/plain', $g->dispatch($r->content)));
	$c->close;
	undef $c;
}

