use strict;
use lib 't';
use Test::Webstellation;

test { action => 'clearAll' }, result => 'ok', 'clear database';
test { action => 'register', userName => '' }, result => 'formatError', 'empty user name';
test { action => 'register', userName => [] }, result => 'formatError', 'array user name';
test { action => 'register', userName => {} }, result => 'formatError', 'hash user name';

test { action => 'joinGame', userName => '', gameName => [] }, result => 'formatError', 'empty user name, array game name';
test { action => 'joinGame', userName => 'John', gameName => '' }, result => 'formatError', 'empty game name';
test { action => 'joinGame', userName => '', gameName => 'game1' }, result => 'formatError', 'empty user name, array game name';

test { action => 'toggleReady' }, result => 'formatError', 'void hash value';
test { action => 'toggleReady', userName => '' }, result => 'formatError', 'empty user name';
test { action => 'toggleReady', userName => [] }, result => 'formatError', 'array user name';
test { action => 'toggleReady', userName => {} }, result => 'formatError', 'hash user name';

test { action => 'logout', userName => '' }, result => 'formatError', 'empty user name';
test { action => 'logout', userName => [] }, result => 'formatError', 'array user name';
test { action => 'logout', userName => {} }, result => 'formatError', 'hash user name';

test { action => 'getGameInfo', gameName => '' }, result => 'formatError', 'empty game name';
test { action => 'getGameInfo', gameName => [] }, result => 'formatError', 'array game name';
test { action => 'getGameInfo', gameName => {} }, result => 'formatError', 'hash game name';

test { action => 'uploadMap' }, result => 'formatError', 'empty mapInfo';
test {
   	action => 'uploadMap',
	mapInfo => {
		name => 'map1',
		planets => [{x => 0, y => 0, size => 1, neighbors => []}]
	}
}, result => 'ok', 'valid mapInfo';
test { action => 'getGameState', gameName => {} }, result => 'formatError', 'gameName is hash in getGameState';

test { action => 'uploadMap',
	mapInfo => {
		name => 'map11',
		planets => [{x => 0, y => 0, size => 'q', neighbors => []}]
	}
}, result => 'formatError', 'string as size of planet';

test { action => 'uploadMap',
	mapInfo => {
		name => 'map11',
		planets => [{x => 0, y => 0, size => -1, neighbors => []}]
	}
}, result => 'badMapInfo', 'negative size of planet';

test { action => 'uploadMap',
	mapInfo => {
		name => 'map11',
		planets => [{x => 0, y => 0, size => 11, neighbors => []}]
	}
}, result => 'badMapInfo', 'too big size of planet';
