#!/usr/bin/perl

use strict;
use lib 't';
use Test::Webstellation;

test { action => 'clearAll' }, result => 'ok', 'clear database';
test { action => 'register', userName => 'Batman' }, result => 'ok', 'register user';

my $betelgeuse = {
	name => 'Betelgeuse', 
	planets => [
		{ x => 0, y => 0, size => 3, neighbors => [] },
		{ x => 1, y => 0, size => 1, neighbors => [] },
		{ x => 0, y => 1, size => 1, neighbors => [] }, ]	
};
test { action => 'uploadMap', mapInfo => $betelgeuse	}, result =>, 'ok', 'upload Betelgeuse';
test 
	{
		action => 'createGame', userName => 'Batman',
		mapName => 'Betelgeuse', maxPlayers => 10,
		gameName => 'MyGame'
	},
	result => 'ok', 
	'createGame';
test { action => 'register', userName => 'A' }, result => 'ok', 'register A';
test { action => 'register', userName => 'B' }, result => 'ok', 'register B';
test { action => 'register', userName => 'C' }, result => 'ok', 'register C';
test { action => 'register', userName => 'D' }, result => 'ok', 'register D';
test { action => 'joinGame', userName => 'A', gameName => 'MyGame' }, result => 'ok', 'join A';
test { action => 'joinGame', userName => 'B', gameName => 'MyGame' }, result => 'ok', 'join B';
test { action => 'joinGame', userName => 'C', gameName => 'MyGame' }, result => 'ok', 'join C';
test { action => 'joinGame', userName => 'D', gameName => 'MyGame' }, result => 'ok', 'join D';
test { action => 'toggleReady', userName => 'A' }, result => 'ok', 'A toggles ready';
test { action => 'toggleReady', userName => 'B' }, result => 'ok', 'B toggles ready';
test { action => 'toggleReady', userName => 'C' }, result => 'ok', 'C toggles ready';
test { action => 'toggleReady', userName => 'D' }, result => 'ok', 'D toggles ready';
test { action => 'leaveGame', userName => 'A' }, result => 'ok', 'A leaves game';
test { action => 'leaveGame', userName => 'B' }, result => 'ok', 'A leaves game';
test { action => 'joinGame', userName => 'A', gameName => 'MyGame' }, result => 'ok', 'join A';
test { action => 'joinGame', userName => 'B', gameName => 'MyGame' }, result => 'ok', 'join B';

test { action => 'joinGame', gameName => 'MyGame', userName => 'Batman' }, result => 'alreadyInGame', 'Batman joins to MyGame';
test { action => 'register', userName => 'Robin' }, result => 'ok', 'register Robin';
test { action => 'joinGame', gameName => 'MyGame', userName => 'Robin' }, result => 'ok', 'Robin joins to MyGame';
test { action => 'leaveGame', userName => 'Jocker' }, result => 'unknownUser', 'Jocker is not registered';
test { action => 'register', userName => 'Jocker' }, result => 'ok', 'register Jocker';
test { action => 'leaveGame', userName => 'Jocker' }, result => 'notInGame', 'Jocker is not in game';
test { action => 'leaveGame', userName => 'Robin' }, result => 'ok', 'Robin leaves games';
