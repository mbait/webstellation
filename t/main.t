#!/usr/bin/perl -w

use strict;
use lib 't';
use Test::Webstellation;

test '', result => 'formatError', 'Invalid JSON';
test 'This is not valid JSON string', result => 'formatError', 'Invalid JSON';
test { action => 'clearAll' }, result => 'ok', 'clear databse';
#test { action => 'getUsers' }, users => [], 'user list', 'is_deeply';
#test { action => 'register', userName => 'Robin' }, result => 'ok', 'register user';
