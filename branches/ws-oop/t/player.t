#!/usr/bin/perl

use strict;
use Test::Webstellation;

test { action => 'clearAll' }, result => 'ok', 'clear database';
test { action => 'getUsers' }, users => [], 'empty list of users', 'is_deeply';
test { action => 'register', userName => 'Jane' },
	result => 'ok', 'register Jane';
test { action => 'register', userName => 'Jack' },
	result => 'ok', 'register Jack';
test { action => 'register', userName => 'Jane' },
	result => 'alreadyTaken', 'register Jane';
test { action => 'logout', userName => 'Jane' },
	result => 'ok', 'logout Jane';
test { action => 'logout', userName => 'Jane' },
	result => 'unknownUser', 'logout Jane';
test { action => 'register', userName => 'John' }, result => 'ok', 'register John';
test { action => 'register', userName => 'Angie' }, result => 'ok', 'register Angie';
test { action => 'getUsers' },
	users => [ 'Angie', 'Jack',  'John', ], 'getUsers', 'is_deeply';

