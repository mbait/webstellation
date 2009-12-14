#!/usr/bin/perl -w

use strict;
use lib 't';
use Test::More;
use Test::Webstellation;

sub is_in{
	my ($res, $ans, $msg) = @_;
	ok grep({ $ans->[0] } @{$res}), $msg;
}

our $host = 'http://watcher.mine.nu/constellation/server';

test { action => 'clearAll' }, result => 'ok', 'clear databse';
my $pid;
for(my $i=0; $i<100; ++$i) {
	waitpid $pid, 0 if $pid;
	$pid = fork;
	my $user = $pid ? 'Superman':'Batman';
	test { action => 'register', userName => $user }, result => 'ok', "register user $user $pid";
	test { action => 'getUsers' }, users => [$user], "user list includes $user", \&is_in; 
	test { action => 'logout', userName => $user }, result => 'ok', "logout user $user $pid";
	last unless $pid;
}
