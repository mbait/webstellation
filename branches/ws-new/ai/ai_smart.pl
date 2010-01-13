#!/usr/bin/perl

use strict;
use warnings;

use LWP::UserAgent;
use HTTP::Request::Common;
use JSON;
use Data::Dumper;

my ($host, $user) = @ARGV;

sub sendRequest {
	my $data = encode_json shift;
	my $ua = LWP::UserAgent->new(agent => 'Webstellation AI');
	my $res = decode_json $ua->request(POST $host, [ r => $data ])->content;
	my $ok = shift;
	if( $ok ) {
		die "error: $res->{result} $res->{message}\nquit now\n" unless $res->{result} eq $ok;
	}
	return $res;
}

sub readConfig {
	my $fname = shift || 'default.cfg';
	open FH, $fname || die "Failed read config from game.cfg: $!";
	my %cfg;
	while(<FH>) {
		chomp;
		next if m/^\s*#/;
		if( m/(.*?)=(.*)/ ) { $cfg{lc$1} = $2 }
		else { warn "Ommiting bad string '$_'" }
	}
	close FH;
	return %cfg;
}

sub waitEvent {
	my ( $min, $max ) = ( 1, 9 );
	print shift, $max;
	for( reverse $min..$max ) {
		print chr(8), $_;
		sleep 1;
	}
	print chr(8), " \n";
}

BEGIN {

my %cfg = readConfig $ARGV[1];
$host = $cfg{host};
$user = $cfg{user};
my $info;
sendRequest({ action => 'register', userName => $cfg{user} }, $cfg{force_enter} ? '' : 'ok');
$| = 1;
print "Try enter game $cfg{game}...\n";
while( 1 ) {
	my $games = sendRequest( { action => 'getGames' } )->{games};
	my ( $game ) = grep { $_ eq $cfg{game} } @{ $games };
	if( $game ) {
		$info = sendRequest( { action => 'getGameInfo', gameName => $game } )->{game};
		last if $info->{status} eq 'preparing';
		waitEvent "Game status is $info->{status}, instead of preparing. Still waiting... ";
	}
	else { 
		waitEvent "There is no such game '$cfg{game}'. Still waiting... ";
	}
}

sendRequest({ action => 'joinGame', userName => $user, gameName => $cfg{game} }, 'ok' );
sendRequest({ action => 'toggleReady', userName => $user }, 'ok' );
$info = sendRequest( { action => 'getGameInfo', gameName => $cfg{game} } )->{game};
my $idx = 0;
my $pos = { map { $_->{name} => $idx++ } @{ $info->{players} } }->{$user};
print "Playing at position $pos\n";
print "=======================\n";

while( 1 ) {
	while( 1 ) {
		last if sendRequest({ action => 'getGameState', gameName => $cfg{game} })->{game}->{active} == $pos;
		sleep $cfg{request_freq};
	}
	last;
}

}
