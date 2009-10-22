use strict;
use lib 't';
use Test::Webstellation;

test { action => 'clearAll' }, result => 'ok', 'clear database';
test { action => 'register', userName => 'A' }, result => 'ok', 'register A';
test { action => 'register', userName => 'B' }, result => 'ok', 'register B';
test { action => 'register', userName => 'C' }, result => 'ok', 'register A';
test { action => 'register', userName => 'D' }, result => 'ok', 'register A';
test { action => 'uploadMap', mapInfo => {
		name => 'Map1',
		planets => [
			{ x => 0, y => 2, size => 2, neighbors => [1, 3, 4] },
			{ x => 2, y => 4, size => 2, neighbors => [0, 2, 5] },
			{ x => 4, y => 2, size => 2, neighbors => [1, 3, 6] },
			{ x => 2, y => 0, size => 2, neighbors => [2, 7, 0] },
			{ x => 1, y => 2, size => 1, neighbors => [0, 5, 7] },
			{ x => 2, y => 3, size => 1, neighbors => [1, 4, 6] },
			{ x => 3, y => 2, size => 1, neighbors => [2, 5, 7] },
			{ x => 3, y => 2, size => 1, neighbors => [3, 4, 6] }
		]
	}
	},
	result => 'ok', 'upload Cassiopeia';
test { action => 'createGame', gameName => 'Game1', userName => 'A', mapName => 'Map1', maxPlayers => 2 }, result => 'ok', 'create game';
test { action => 'joinGame', userName => 'B', gameName => 'Game1' }, result => 'ok', 'B joins to Game1';
# Let the battle begin!
test { action => 'move', userName => 'C', planet => 1 }, result => 'notInGame', 'game is not started and out-of-game user tries to move';
test { action => 'toggleReady', userName => 'A' }, result => 'ok', 'A toggles ready';
test { action => 'toggleReady', userName => 'B' }, result => 'ok', 'A toggles ready';
test { action => 'move', userName => 'B', planet => 0 }, result => 'notYourTurn', 'B tries to move';
test { action => 'move', userName => 'A', planet => 32000 }, result => 'badPlanet', 'A move on bad planet';
test { action => 'move', userName => 'Z', planet => 0 }, result => 'notInGame', 'unregistered user tries to move';
test { action => 'move', userName => 'C', planet => 0 }, result => 'notInGame', 'out-of-game user tries to move';
test { action => 'move', userName => 'B', planet => 32000 }, result => 'notYourTurn', 'B tries to move and bad planet';
