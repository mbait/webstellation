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

sub calcMoveProfit {
	my ( $map, $old_state, $idx ) = @_;
	my $state;
	eval Data::Dumper->Dump( [ $old_state ], ['state'] );
	$state->{planets}->[$idx]->{owner} = $state->{active};
	++$state->{planets}->[$idx]->{bases};
	my @changed;
	do {
		@changed = ();
		my $index = 0;
		for my $p(@{$state->{planets}}) {
			my %inf;
		   	%inf = ( $p->{owner} => $p->{bases} ) if defined $p->{owner} && $p->{bases};
			for(map { $state->{planets}->[$_] } @{$map->{planets}->[$index]->{neighbors}}) {
				 $inf{$_->{owner}} += $_->{bases} if defined $_->{owner} && $_->{bases};
			}
			unless( %inf ) {
				$p->{owner} = undef;
				$p->{bases} = 0;
			}
			my @max = reverse sort { $inf{$a} <=> $inf{$b} } keys %inf; 
			@max = grep { $inf{$_} > $inf{$p->{owner}} } @max if defined $p->{owner} && $p->{bases};
			if(@max) {
				my ($new, $new2) = @max;
				$new = undef if defined $new2 && $inf{$new} == $inf{$new2};
				push @changed, { ind => $index, owner => $new } if $new ne $p->{owner};
			}
			++$index;
		}
		for(@changed) {
			my $p = $state->{planets}->[$_->{ind}];
			$p->{owner} = $_->{owner};
			$p->{bases} = 0;
		}
	}while(@changed);
	
	my $score = 0;
	for my $p ( @{ $state->{planets} } ) {
		$score += $p->{bases} if $p->{owner} && $p->{owner} == $state->{active};
	}
	return $score - $old_state->{score}->[ $old_state->{active} ]->{bases};
}

sub makeMove {
	my( $map, $state, @planets ) = @_;
	my @idx = sort { $a->[1] <=> $b->[1] } map { [ $_, calcMoveProfit( $map, $state, $_ ) ] } @planets;
	@idx = 
		sort { $map->{planets}->[ $b->[0] ]->{size} <=> $map->{planets}->[ $a->[0] ]->{size} } 
		grep { $_->[1] == $idx[0]->[1] } @idx;
	return $idx[0]->[0];
}

BEGIN {

my %cfg = readConfig $ARGV[1];
$host = $cfg{host};
$user = $cfg{user};
my $info;
sendRequest({ action => 'register', userName => $cfg{user} }, $cfg{force_enter} ? '' : 'ok');
$| = 1;
print "Try enter game '$cfg{game}'...\n";
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
print "Map name is '$info->{map}'\n";
print "=======================\n";

my $map = sendRequest({ action => 'getMapInfo', mapName => $info->{map} })->{'map'};
my $state;
MAIN: while( 1 ) {
	while( 1 ) {
		last MAIN if sendRequest({ action => 'getGameInfo', gameName => $cfg{game} })->{game}->{status} ne 'playing';
		$state = sendRequest({ action => 'getGameState', gameName => $cfg{game} })->{game};
		last if $state->{active} == $pos;
		sleep $cfg{request_freq};
	}
	$idx = 0;
	my @planets = map { $_->{idx} = $idx++; $_ } @{ $state->{planets} };
	@planets = map { $_->{idx} } 
		grep { !$_->{bases} || $_->{owner} == $pos && $_->{bases} < $map->{planets}->[ $_->{idx} ]->{size} } @planets;
	unless( @planets ) {
		# Yoda notation is not an error
		print "To move on there are no planets. Good game was it\n";
		last MAIN;
	}
	$idx = makeMove( $map, $state, @planets );
	print "Move on planet $idx\n";
	sendRequest({ action => 'move', userName => $user, planet => $idx }, 'ok' );
}
sendRequest({ action => 'logout', userName => $user });

}
