#!/usr/bin/perl -w

use strict;
use JSON::XS;

my %games;
my %players;
my %maps;

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
	if(exists $games{$game}) { return { result => 'gameExists' }; }
	elsif($players{$user}) { return { result => 'alreadyInGame' }; }
	else {
		$games{$game} = (
				
		);
	}
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

sub test {
	my $res = decode_json(response encode_json $_[0]);
	$_[1]->($res);
}

test { 
		userName	=>	'John',
		action		=>	'register'
	},
	sub { 
		is($_[0]->{'result'}, 'OK', 'Register user');
		ok(exists $players{'John'}, 'internal');
	};

test {
		userName	=>	'Jane',
		action		=>	'register'
	},
	sub {
		is($_[0]->{'result'}, 'OK', 'Register another user');
		ok(exists $players{'Jane'}, 'internal');
	};

test {
		userName	=>	'John',
		action		=>	'register'
	},
	sub {
		is($_[0]->{'result'}, 'alreadyTaken', 'Register existing user');
	};
		
test {
		userName	=>	'John',
		action		=> 'logout'
	},
	sub {
		is($_[0]->{'result'}, 'OK', 'Logout user');
		ok(not (exists $players{'John'}), 'internal');	
	};

test {
		userName	=>	'Jack',
		action		=>	'logout'
	},
	sub {
		is($_[0]->{'result'}, 'unknownUser', 'Logout unexisting user');
	};

test {
		action		=>	'getUsers'
	},
	sub {
		#my @users = @$_[0]->{'users'};
	};
