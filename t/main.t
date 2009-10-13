#!/usr/bin/perl -w

use strict;
use Test::Webstellation;

test '', result => 'formatError', 'Invalid JSON';
test 'This is not valid JSON string', result => 'formatError', 'Invalid JSON';
test { action => 'register', userName => 'Robin' }, result => 'ok', 'register user';
test { action => 'clear' }, result => 'ok', 'clear databse';
test { action => 'getUsers' }, users => [], 'user list', 'is_deeply';
