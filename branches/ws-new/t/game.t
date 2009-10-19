#!/usr/bin/perl

use strict;
use lib 't';
use Test::Webstellation;

test { action => 'clear' }, result => 'ok', 'clear database';
test { action => 'getGames' }, games => [], 'empty list of games', 'is_deeply';
test { action => 'register', userName => 'Jack' }, result => 'ok', 'register Jack';
my $aldebaran =  {
	name => 'Aldebaran', 
	planets => [
		{ x => 0, y => 0, size => 3, neighbors => [] },
		{ x => 1, y => 0, size => 1, neighbors => [] },
		{ x => 0, y => 1, size => 1, neighbors => [] },
	]
};
test { action => 'uploadMap', mapInfo => $aldebaran }, result => 'ok', 'upload Aldebaran';
test 
	{
		action => 'createGame', userName => 'Jack',
		mapName => 'Aldebaran', maxPlayers => 3,
		gameName => 'Game1'
	},
	result => 'ok', 
	'createGame';

test 
	{
		action => 'createGame', userName => 'Ann',
		mapName => 'Aldebaran', maxPlayers => 3,
		gameName => 'error'
	},
	result => 'unknownUser',
	'createGame with bad user';

test
	{
		action => 'createGame', userName => 'Jack',
		mapName => 'Aldebaran', maxPlayers => 3,
		gameName => 'Game1'
	},
	result => 'gameExists',
	'createGame existing';

test
	{
		action => 'createGame', userName => 'Jack',
		mapName => 'Venus', maxPlayers => 3,
		gameName => 'nogame'
	},
	result => 'unknownMap',
	'createGame with bad map';
test { action => 'register', userName => 'John' }, result => 'ok', 'register John';
test 
	{
		action => 'createGame', userName => 'John',
		mapName => 'Aldebaran', maxPlayers => 3,
		gameName => 'Game0'
	},
	result => 'ok', 
	'createGame';
test { action => 'getGames' }, games => [qw/Game0 Game1/], 'get games', 'is_deeply';
test { action => 'getGameInfo', gameName => 'Game1' }, game =>
	{
		name => 'Game1', 
		maxPlayers => 3,
		'map' => 'Aldebaran',
		status => 'preparing',
		players => [{name => 'Jack', isReady => 0}]
	},
	'get game info', 'is_deeply';
test { action => 'register', userName => 'Alex' }, result => 'ok', 'register Alex';
test { action => 'joinGame', userName => 'Alex', gameName => 'Game1' }, result => 'ok', 'join game';

test { action => 'getGameInfo', gameName => 'Game1' }, game =>
	{
		name => 'Game1', 
		maxPlayers => 3,
		'map' => 'Aldebaran',
		status => 'preparing',
		players => [{name => 'Jack', isReady => 0}, {name => 'Alex', isReady => 0}]
	},
	'get game info', 'is_deeply';
