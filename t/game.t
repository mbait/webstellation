#!/usr/bin/perl

use strict;
use Test::Webstellation;

test { action => 'clear' }, result => 'ok', 'clear database';
test { action => 'getGames' }, games => [], 'empty list of games', 'is_deeply';
test { action => 'register', userName => 'Jack' }, result => 'ok', 'register Jack';
my $aldebaran =  {
	name => 'Aldebaran', 
	planets => [
		{ x => 0, y => 0, size => 3, neighbors => [1] },
		{ x => 1, y => 0, size => 1, neighbors => [1] },
		{ x => 0, y => 1, size => 1, neighbors => [1] },
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

