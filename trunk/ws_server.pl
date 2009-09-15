#!/usr/bin/perl -w

use strict;
use JSON::XS;

my %games;
my %players;

sub register {
	my $name = $_[0]->{"userName"};
	unless(exists $players{$name}) { 
		$players{$name} = undef; 
		return { result => 'OK', message => "You've been added" }; 
	}
	else {
		return { 
			result	=> 'alreadyTaken', 
			message	=> "Name '$name' is already taken" };
	}
}

sub getUsers {
	return { users => [keys %players], result => 'OK' };
}

sub logout {
	my $name = $_[0]->{"userName"};
	if(exists $players{$name}) {
		delete $players{$name};
		return { result => 'OK' };
	}
	else {
		return {
			result	=> 'unknownUser',
			message	=> 'No such user'
		};
	}
}

sub getGames {
	return { games => [ keys %games], result => 'OK' };
}

sub	createGame {
	my $user = $_[0]->{'UserName'};
	my $game = $_[0]->{'gameName'};

}

my %callback = (
	register	=>	\&register,
	getusers	=>	\&getUsers,
	logout		=>	\&logout,
	getgames	=>	\&getGames,	
);

sub response {
	my $data = decode_json $_[0];
	my $cmd = lc $data->{"action"};
	if(exists $callback{$cmd}) { return encode_json $callback{$cmd}->($data); }
	else { die "fail"; }
}

use Test::More qw 'no_plan';

sub dbg_print {
}

response my $data = encode_json {
	userName	=> "John",
	action		=> "register",
};

response encode_json {
	userName	=> "Jane",
	action		=> "register",
};

response encode_json {
	userName 	=>	"Jack",
	action		=>	"register",
};

my $ans = response encode_json { action	=>	'getUsers' };
print ($ans);

response encode_json {
	userName	=>	'Jack',
	action		=>	'logout'
};

print response encode_json {
	userName	=>	'Kate',
	action		=>	'logout'
};
