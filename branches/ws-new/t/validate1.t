use strict;
use Test::Webstellation;

test { action => 'clear' }, result => 'ok', 'clear database';
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
