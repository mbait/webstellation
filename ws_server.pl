#!/usr/bin/perl -w

use warnings;
use strict;
use JSON::XS;
use File::Temp 'tempfile';
use WS::Request;
use Net::HTTP;

use Test::More qw 'no_plan';
use Data::Dumper;


my ($fh, $fname) = tempfile('tmpXXXX', DIR => '/tmp');
my $host;

sub wrap {
	my $result;
	if($host) {
		my $r = Net::HTTP->new(Host => 'localhost', PeerPort => 4440);
		$r->write_request(POST => '/', 'User-Agent' => 'Mozilla/5.0', 'r='.encode_json shift);
		while (1) {
			my $body;
			my $n = $r->read_entity_body($body, 1024);
			die "read failed: $!" unless defined $n;
			last unless $n;
			$result .= $body;
		}
		#print "$result\n";
	}
	else {
		my $r = WS::Request->new($fname);
		$result = $r->dispatch(encode_json shift);
	}
	return decode_json $result;
}

sub test {
	$host = shift if @_;

	my $res = wrap { 
			action => 'register', userName => 'Jane' 
		};
	is($res->{'result'}, 'OK', 'register Jane');

	$res = wrap {
			action => 'register', userName => 'Jack'
		};
	is($res->{'result'}, 'OK', 'register Jack');

	$res = wrap {
			action => 'register', userName => 'Jane'
		};
	is($res->{'result'}, 'alreadyTaken', 'register Jane');

	$res = wrap {
			action => 'logout', userName => 'Jane'
		};
	is($res->{'result'}, 'OK', 'logout Jane');

	$res = wrap {
			action => 'logout', userName => 'Jane'
		};
	is($res->{'result'}, 'unknownUser', 'logout Jane');

	wrap {
			action => 'register', userName => 'John'
		};
	wrap {
			action	=> 'register', userName => 'Angie'
		};
	$res = wrap {
			action => 'getUsers'
		};
	#print Dumper (sort {$a cmp $b} @{$res->{'users'}});
	is_deeply $res->{'users'}, [
		{ name =>'Angie', isReady => 0 }, 
		{ name =>'Jack', isReady => 0 }, 
		{ name => 'John', isReady => 0 }
	], 'getUsers';	

	$res = wrap {
		action => 'uploadMap', mapInfo => {
			name => 'Aldebaran', planets => [
				{ x => 0, y => 0, size => 3 },
				{ x => 1, y => 0, size => 1 },
				{ x => 0, y => 1, size => 1 },
			]	
		}
	};
	is($res->{'result'}, 'OK', 'upload Aldebaran');
	
	$res = wrap {
		action => 'uploadMap', mapInfo => {
			name => 'NGC 2238', planets => [
				{ x => 0, y => 0, size => 3 },
				{ x => 1, y => 0, size => 1 },
				{ x => 0, y => 1, size => 1 },
			]	
		}
	};
	is($res->{'result'}, 'OK', 'upload NGC 2238');

	$res = wrap {
		action => 'uploadMap', mapInfo => {
			name => 'Betelgeuse', planets => [
				{ x => 0, y => 0, size => 3 },
				{ x => 1, y => 0, size => 1 },
				{ x => 0, y => 1, size => 1 },
			]	
		}
	};
	is($res->{'result'}, 'OK', 'upload Betelgeuse');

	$res = wrap {
		action => 'uploadMap', mapInfo => {
			name => 'Cassiopeia', planets => [
				{ x => 0, y => 0, size => 3 },
				{ x => 1, y => 0, size => 1 },
				{ x => 0, y => 1, size => 1 },
			]	
		}
	};
	is($res->{'result'}, 'OK', 'upload Cassiopeia');

	$res = wrap {
		action => 'uploadMap', mapInfo => {
			name => 'Cassiopeia', planets => [
				{ x => 0, y => 0, size => 3 },
				{ x => 1, y => 0, size => 1 },
				{ x => 0, y => 1, size => 1 },
			]	
		}
	};
	is($res->{'result'}, 'mapExists', 'upload Cassiopeia again');

	$res = wrap {
		action => 'getMaps'
	};
	is_deeply $res->{'maps'}, ['Aldebaran', 'Betelgeuse', 'Cassiopeia', 'NGC 2238'], 'getMaps';

	$res = wrap {
		action => 'getMapInfo', mapName => 'Cassiopeia' };
	is_deeply $res->{'mapInfo'}, {
		name => 'Cassiopeia', planets => [
			{ x => 0, y => 0, size => 3 },
			{ x => 1, y => 0, size => 1 },
			{ x => 0, y => 1, size => 1 },
		]	
	}, 'getMapInfo';
	
	$res = wrap {
		action => 'createGame', userName => 'Jack',
		mapName => 'Aldebaran', maxPlayers => 3,
		gameName => 'Game1'
	};
	is $res->{'result'}, 'OK', 'createGame';

	$res = wrap {
		action => 'createGame', userName => 'Ann',
		mapName => 'Aldebaran', maxPlayers => 3,
		gameName => 'error'
	};
	is $res->{'result'}, 'unknownUser', 'createGame with bad user';

	$res = wrap {
		action => 'createGame', userName => 'John',
		mapName => 'Aldebaran', maxPlayers => 3,
		gameName => 'Game1'
	};
	is $res->{'result'}, 'gameExists', 'createGame existing';

	$res = wrap {
		action => 'createGame', userName => 'John',
		mapName => 'Venus', maxPlayers => 3,
		gameName => 'error'
	};
	is $res->{'result'}, 'unknownMap', 'createGame with bad map';
}

test;
print "\nREMOTE TESTING\n\n";
test 'localhost:4440';

