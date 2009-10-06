#!/usr/bin/perl -w

use warnings;
use strict;

use HTTP::Daemon;
use HTTP::Status;
use HTTP::Headers;
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
	warn "Failed to read server.conf: $!\nUsing defaults\n";
}

our $pid = fork; 
die "Failed to fork: $!\n" unless defined $pid;
if($pid) {
	# Kill child on ^C
	$SIG{INT} = sub { kill $pid; };
	# We are parent and must wait
	waitpid $pid, 0;
	print "\nShuting down...\n";
}
else {
	print "Starting game server...\n";
	my $g = Webstellation::Request->new($conf{'dbfile'});
	print "Starting web server...\n";
	my $d = HTTP::Daemon->new(LocalPort => $conf{'port'}) or die $!;
	print "Listening on port $conf{'port'}\n";

	while(my $c = $d->accept) {
		my $r = $c->get_request;
		$c->send_error(RC_NOT_IMPLEMENTED) unless $r->method eq 'POST';
		$c->send_error(RC_FORBIDDEN) unless $r->uri->path eq '/';

		$r->content =~ /r=(.*)/;
		print "$1\n";
		$c->send_response(HTTP::Response->new(200, status_message(200),
			   HTTP::Headers->new(Content_Type => 'text/plain'), $g->dispatch($1)));
		$c->close;
		undef $c;
	}
}
