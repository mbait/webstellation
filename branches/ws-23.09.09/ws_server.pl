#!/usr/bin/perl -w

use warnings;
use strict;
use JSON::XS;
use File::Temp 'tempfile';
use WS::Request;

use Test::More qw 'no_plan';

sub test {
	my ($fh, $fname) = tempfile('tmpXXXX', DIR => '/tmp');
	sub wrap {
		my $r = WS::Request->new($fname);
		return decode_json $r->dispatch(encode_json shift);
	}

	my $res = wrap { 
			action => 'register', userName => 'Jane' 
		};
	is($res->{'result'}, 'OK', 'register Jack');

	$res = wrap {
			action => 'register', userName => 'Jack'
		};
	is($res->{'result'}, 'OK', 'register Jane');

	$res = wrap {
			action => 'register', userName => 'Jane'
		};
	is($res->{'result'}, 'alreadyTaken', 'register Jane');

	$res = wrap {
			action => 'logout', userName => 'Jane'
		};
	is($res->{'result'}, 'OK', 'logout Jane');

	$res = wrap {
			action => 'logout', userName => 'Jane'
		};
	is($res->{'result'}, 'unknownUser', 'logout Jane');

	wrap {
			action => 'register', userName => 'John'
		};
	$res = wrap {
			action => 'getUsers'
		};
	is_deeply $res->{'users'}, ['Jack', 'John'], 'getUsers';	
}

test;

;
