#!/usr/bin/perl -w

use lib 'lib';
use warnings;
use strict;
use JSON::XS;
use File::Temp 'tempfile';

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
	my ($fh, $fname) = tempfile('tmpXXXX', DIR => '/tmp');
	my $r = Request->new($fname);
	my $res = decode_json $r->dispatch(encode_json { 
			action => 'register', userName => 'Jane' 
		});
	is($res->{'result'}, 'OK', 'register Jack');

	$res = decode_json $r->dispatch(encode_json {
			action => 'register', userName => 'Jack'
		});
	is($res->{'result'}, 'OK', 'register Jane');

	$res = decode_json $r->dispatch(encode_json {
			action => 'register', userName => 'Jane'
		});
	is($res->{'result'}, 'alreadyTaken', 'register Jane');

	$res = decode_json $r->dispatch(encode_json {
			action => 'logout', userName => 'Jane'
		});
	is($res->{'result'}, 'OK', 'logout Jane');

	$res = decode_json $r->dispatch(encode_json {
			action => 'logout', userName => 'Jane'
		});
	is($res->{'result'}, 'unknownUser', 'logout Jane');

	$r->dispatch(encode_json {
			action => 'register', userName => 'John'
		});
	$res = decode_json $r->dispatch(encode_json {
			action => 'getUsers'
		});
	is_deeply $res->{'users'}, ['Jack', 'John'], 'getUsers';	
}

test;

package Request;

use strict;
#use Tie::DB_Lock;
use DB_File;
use Data::Dumper;
use JSON::XS;

sub new {
	my $invocant = shift;
	my $class = ref($invocant) || $invocant;
	my $self = { dbfile => shift || 'data'};
	return bless $self, $class;
}

sub db_open {
	my $self = shift;
	my %dbhash;
	tie(%dbhash, 'DB_File', $self->{'dbfile'});
	$self->{'dbhash'} = \%dbhash;
}

sub db_extract {
	my $self = shift;
	my $dbhash = $self->{'dbhash'};
	$self->{'dbdata'} = [];
	my @dbdata;
	for(@_) {
		eval $$dbhash{$_} if exists $$dbhash{$_};
		push @dbdata, $_;
	}
	$self->{'dbdata'} = \@dbdata;
}

sub db_close {
	my $self = shift;
	my $dbhash = $self->{'dbhash'};
	my $dbdata = $self->{'dbdata'};
	for(@$dbdata) {
		$$dbhash{$_} = Data::Dumper->Dump([$self->{$_}], ["\$self->{'$_'}"]);
	}
	untie %{$self->{'dbhash'}};
}

sub dispatch {
	my $self = shift;
	my $args = decode_json shift;
	$self->db_open;
	my $res;
	{
		no strict 'refs';
		$res = $args->{'action'}->($self, $args);
	}
	$self->db_close;
	return encode_json $res;
}

# Request procedures

sub register {
	my $self = shift;
	$self->db_extract(qw/players playerNames/);
	my $args = shift;
	my $players = $self->{'players'} ||= {};
	if(exists $players->{$args->{'userName'}}) {
		return { result => 'alreadyTaken' };
	}
	my $playerNames = $self->{'playerNames'} ||= [];
	push @$playerNames, $args->{'userName'}; 
	$$players{$args->{'userName'}} = $#$playerNames;
	return { result => 'OK' };
}

sub logout {
	my $self = shift;
	$self->db_extract(qw/players playerNames/);
	my $args = shift;
	my $players = \%{$self->{'players'}};
	unless(exists $$players{$args->{'userName'}}) {
		return { result => 'unknownUser' };
	}
	my $playerNames = \@{$self->{'playerNames'}};
	splice @$playerNames, $$players{$args->{'userName'}}, 1;
	delete $$players{$args->{'userName'}};
	return { result => 'OK' };
}

sub getUsers {
	my $self = shift;
	$self->db_extract('playerNames');
	return { users => $self->{'playerNames'}, result => 'OK' };
}

1;
