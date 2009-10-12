#!/usr/bin/perl -w

use warnings;
use strict;
use JSON::XS;
use File::Temp 'tempfile';
use Webstellation::Request;
use LWP::UserAgent;
use HTTP::Request::Common;

use Test::More qw 'no_plan';
use Data::Dumper;


my ($fh, $fname) = tempfile('tmpXXXX', DIR => '/tmp');
my $host;

sub wrap {
	my $result;
	if($host) {
		#my ($addr, $port) = split /:/, $host;
		my $ua = LWP::UserAgent->new(agent => 'Webstellation test system');
		my $res = $ua->request(POST $host, [ r => encode_json shift ]);
		#skip $res->content unless $res->is_success;
		my $content = $res->content;
		chomp $content;
		skip $content unless $res->is_success;
		$result = $res->content;
	}
	else {
		my $r = Webstellation::Request->new($fname);
		$result = $r->dispatch(encode_json shift);
	}
	return $result;
}

sub wrap_is {
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
			if(defined $sub) {
				$sub->($res->{$key}, $ans, $msg);
			}
			else {
				is $res->{$key}, $ans, $msg;
			}
		}
	}
}

sub test {
	$host = shift if @_;

	wrap_is { action => 'clear' }, result => 'ok', 'clear database';
	wrap_is { action => 'getGames' }, games => [], 'getGames', \&is_deeply;
	wrap_is { action => 'register', userName => 'Jane' },
		result => 'ok', 'register Jane';
	wrap_is { action => 'register', userName => 'Jack' },
		result => 'ok', 'register Jack';
	wrap_is { action => 'register', userName => 'Jane' },
		result => 'alreadyTaken', 'register Jane';

	wrap_is { action => 'logout', userName => 'Jane' },
		result => 'ok', 'logout Jane';
	wrap_is { action => 'logout', userName => 'Jane' },
		result => 'unknownUser', 'logout Jane';
	wrap_is { action => 'register', userName => 'John' }, result => 'ok', 'register John';
	wrap_is { action => 'register', userName => 'Angie' }, result => 'ok', 'register Angie';
	wrap_is { action => 'getUsers' },
		users => [ 'Angie', 'Jack',  'John', ], 'getUsers', \&is_deeply;

	my $aldebaran =  {
	   	name => 'Aldebaran', 
		planets => [
			{ x => 0, y => 0, size => 3, neighbors => [1] },
			{ x => 1, y => 0, size => 1, neighbors => [1] },
			{ x => 0, y => 1, size => 1, neighbors => [1] },
		]
	};
	wrap_is { action => 'uploadMap', mapInfo => $aldebaran }, result => 'ok', 'upload Aldebaran';
	my $ngc2238 = {
		name => 'NGC 2238', 
		planets => [
			{ x => 0, y => 0, size => 3, neighbors => [3] },
			{ x => 1, y => 0, size => 1, neighbors => [1] },
			{ x => 0, y => 1, size => 1, neighbors => [2] },
		]	
	};
	wrap_is { action => 'uploadMap', mapInfo => $ngc2238 }, result => 'ok', 'upload NGC 2238';
	my $betelgeuse = {
		name => 'Betelgeuse', 
		planets => [
			{ x => 0, y => 0, size => 3, neighbors => [1] },
			{ x => 1, y => 0, size => 1, neighbors => [1] },
			{ x => 0, y => 1, size => 1, neighbors => [1] },
		]	
	};
	wrap_is { action => 'uploadMap', mapInfo => $betelgeuse	}, result =>, 'ok', 'upload Betelgeuse';
	my $cassiopeia = {
		name => 'Cassiopeia', 
		planets => [
			{ x => 0, y => 0, size => 3, neighbors => [1] },
			{ x => 1, y => 0, size => 1, neighbors => [1] },
			{ x => 0, y => 1, size => 1, neighbors => [1] },
		]	
	};
	wrap_is { action => 'uploadMap', mapInfo => $cassiopeia	}, result => 'ok', 'upload Cassiopeia';
	wrap_is { action => 'uploadMap', mapInfo => $cassiopeia	}, result => 'mapExists', 'upload Cassiopeia again';
	wrap_is { action => 'getMaps' }, maps => ['Aldebaran', 'Betelgeuse', 'Cassiopeia', 'NGC 2238'], 'getMaps', \&is_deeply;
	wrap_is { action => 'getMapInfo', mapName => 'Cassiopeia' }, 'map' => $cassiopeia, 'getMapInfo', \&is_deeply; 

	wrap_is 
		{
			action => 'createGame', userName => 'Jack',
			mapName => 'Aldebaran', maxPlayers => 3,
			gameName => 'Game1'
		},
		result => 'ok', 
		'createGame';

	wrap_is 
		{
			action => 'createGame', userName => 'Ann',
			mapName => 'Aldebaran', maxPlayers => 3,
			gameName => 'error'
		},
		result => 'unknownUser',
		'createGame with bad user';

	wrap_is
		{
			action => 'createGame', userName => 'John',
			mapName => 'Aldebaran', maxPlayers => 3,
			gameName => 'Game1'
		},
		result => 'gameExists',
		'createGame existing';

	wrap_is
		{
			action => 'createGame', userName => 'John',
			mapName => 'Venus', maxPlayers => 3,
			gameName => 'error'
		},
		result => 'unknownMap',
		'createGame with bad map';
}

test;
#print "\nREMOTE TESTING\n\n";
#test 'http://localhost:8080';
#test 'http://watcher.mine.nu/constellation/';
