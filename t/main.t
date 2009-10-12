#!/usr/bin/perl -w

use strict;
use Test::Webstellation;

test '', result => 'formatError', 'Invalid JSON';
test 'This is not valid JSON string', result => 'formatError', 'Invalid JSON';
