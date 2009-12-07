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
	my $res = $ua->request(POST $host, [ r => $data ]);
	return decode_json $res->content;
}

die 'Usage: ai_dumb.pl <host> <user>' unless $host && $user;

my $r = sendRequest ({action => 'register', userName => $user});
$\ = "\n";

my ($game, $ingame, $ready, $index);
do {
	print 'Fetching game list..';
	$r = sendRequest ({action => 'getGames'});
	for(@{$r->{games}}) {
		print "\t-> $_";
		my $info = sendRequest {action => 'getGameInfo', gameName => $_ };
		$info = $info->{game};
		#unless($ingame) {
		#	for(my $i=0; $i<@{$info->{players}}; ++$i) {
		#		$ready = $info->{players}->[$i]->{isReady};
		#		$ingame = 1 if $info->{players}->[$i]->{name} eq $user;
		#		last if $ingame;
		#	}
		#	$game = $info->{name} if $ingame;
		#}
		my ($me) = grep { $_->{name} eq $user } @{$info->{players}};
		if($me) {
			$game = $info->{name};
			$ready = $me->{isReady};
			$ingame = 1;
		}
		unless($game) {
			if($info->{maxPlayers} > @{$info->{players}}) {
				$game = $info->{name};
			}
		}
	}
	unless($game) {
		print 'There is no suitable game. Wait 5 seconds...';
		sleep 5;
	}
} until($game);

if($ingame) { print "Already in game '$game'".($ready?' and ready':'') }
else { 
	print "Entering game '$game'..." ;
	$r = sendRequest {action => 'joinGame', gameName => $game, userName => $user};
	die 'Failed to enter' unless $r->{result} eq 'ok';
}
sendRequest { action => 'toggleReady', userName => $user } unless($ready);
print 'Wait while game will start...';
do {
	sleep 2;
	$r = sendRequest { action => 'getGameInfo', gameName => $game };

	for($index=0;$index<@{$r->{game}->{players}}; ++$index) {
		last if $r->{game}->{players}->[$index]->{name} eq $user;
	}
} until($r->{game}->{status} eq 'playing');
print "Fetching map data ($r->{game}->{map})...";
$r = sendRequest { action => 'getMapInfo', mapName => $r->{game}->{'map'} };
die "Cannot fetch map data: $r->{result}($r->{message})" unless $r->{result} eq 'ok';
my $map = $r->{'map'}->{planets};
print "Wait self order ($index)...";
while(1) {
	sleep 2;
	$r = sendRequest { action => 'getGameState', gameName => $game };
	my $state = $r->{game};
	# our turn
	if($state->{active} == $index) {
		my $i = 0;
		my @planets = 
			grep {!$_->{bases} || $_->{owner} eq $index && $_->{bases} < $map->[$_->{ind}]->{size} } 
			map { {%{$_}, ind => $i++ } }@{$state->{planets}};
		unless(@planets) {
			print "These are no planets to move. Quit now";
			exit;
		}
		print "Move on $planets[0]->{ind}th planet";
		sendRequest { action => 'move', userName => $user, planet => $planets[0]->{ind} };
	}
}
