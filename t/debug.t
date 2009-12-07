#!/usr/bin/perl

use strict;
use lib 't';
use Test::Webstellation;

test { action => 'clearAll' }, result => 'ok', 'clear DB';
my $test = {
	name => 'test',
	planets => [
		{ x => 0, y => 0, size => 2, neighbors => [5, 8] },
		{ x => 4, y => 0, size => 2, neighbors => [6, 8] },
		{ x => 0, y => 4, size => 2, neighbors => [5, 7] },
		{ x => 4, y => 4, size => 2, neighbors => [6, 7] },
		{ x => 2, y => 2, size => 3, neighbors => [5, 6, 7, 8] },
		{ x => 1, y => 2, size => 1, neighbors => [0, 2, 4] },
		{ x => 3, y => 2, size => 1, neighbors => [1, 3, 4] },
		{ x => 2, y => 3, size => 1, neighbors => [2, 3, 4] },
		{ x => 2, y => 1, size => 1, neighbors => [0, 1, 4] }
	]
};
test { action => 'uploadMap', mapInfo => $test }, result => 'ok', 'upload test';
test { action => 'register', userName => 'player1' }, result => 'ok', 'register player1';
test { action => 'register', userName => 'player2' }, result => 'ok', 'register player2';
test { action => 'createGame', userName => 'player1', gameName => 'game1', mapName => 'test', maxPlayers => 2 }, result => 'ok';
test { action => 'joinGame', userName => 'player2', gameName => 'game1' }, result => 'ok';
test { action => 'toggleReady', userName => 'player1' }, result => 'ok';
test { action => 'toggleReady', userName => 'player2' }, result => 'ok';
