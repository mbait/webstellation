#!/usr/bin/perl

use strict;
use Test::Webstellation;

test { action => 'clear' }, result => 'ok', 'clear database';
test { action => 'register', userName => 'Batman' }, result => 'ok', 'register user';

my $betelgeuse = {
	name => 'Betelgeuse', 
	planets => [
		{ x => 0, y => 0, size => 3, neighbors => [] },
		{ x => 1, y => 0, size => 1, neighbors => [] },
		{ x => 0, y => 1, size => 1, neighbors => [] },
	]	
};
test { action => 'uploadMap', mapInfo => $betelgeuse	}, result =>, 'ok', 'upload Betelgeuse';
test 
	{
		action => 'createGame', userName => 'Batman',
		mapName => 'Betelgeuse', maxPlayers => 3,
		gameName => 'MyGame'
	},
	result => 'ok', 
	'createGame';
test { action => 'joinGame', gameName => 'MyGame', userName => 'Batman' }, result => 'alreadyInGame', 'Batman joins to MyGame';
test { action => 'register', userName => 'Robin' }, result => 'ok', 'register Robin';
test { action => 'joinGame', gameName => 'MyGame', userName => 'Robin' }, result => 'ok', 'Robin joins to MyGame';
test { action => 'leaveGame', userName => 'Jocker' }, result => 'unknownUser', 'Jocker is not registered';
test { action => 'register', userName => 'Jocker' }, result => 'ok', 'register Jocker';
test { action => 'leaveGame', userName => 'Jocker' }, result => 'notInGame', 'Jocker is not in game';
test { action => 'leaveGame', userName => 'Robin' }, result => 'ok', 'Robin leaves games';
