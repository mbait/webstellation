#!/usr/bin/perl -w

use strict;
use JSON::XS;

sub	response {
	my $var = decode_json $_[0];
	my $act = 'Request::'.$var->{'action'};
	{
		no strict 'refs';
		&$act;
	}
}

use Test::More qw 'no_plan';

sub test {
	 my $r = decode_json (response (encode_json ({ userName => 'Jayson', action => 'register' })));
	 is $r->{'result'}, 'OK';

	  $r =  (response (encode_json ({ action => 'getUsers'})));
	  print $r;
}

test;

#response encode_json { request => 'register' };

package Request;

use strict;
use Tie::DB_Lock;
use DB_File;
use Data::Dumper;
use JSON::XS;

our $filename = 'data';

sub register {
	my %hash;
	tie(%hash, 'Tie::DB_Lock', 'data', 'rw') or die 'Failed to open database';
	my @players;
	eval $hash{'players'} if exists $hash{'players'};
	my $args = decode_json($_[0]);

	# search duplicates
	my %users;
	$users{$_} = 1 for @players;
	if(exists $users{$args->{'userName'}}) {
		untie %hash;
		return encode_json { result => 'alreadyTaken' };
	}

	push @players, $args->{'userName'};
	$hash{'players'} = Data::Dumper->Dump([\@players], ['*players']);
	untie %hash;
	return encode_json {
		result => 'OK'
	}
}

sub getUsers {
	my %hash;
	tie(%hash, 'Tie::DB_Lock', 'data', 'r') or die 'Filed to open database';
	my @players;
	eval $hash{'players'};
	untie %hash;
	return encode_json { 
		users => \@players,
		result => 'OK'
	};
}

1;
