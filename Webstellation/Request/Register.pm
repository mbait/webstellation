package Webstellation::Request::Register;

use strict;
use warnings;

use Webstellation::Request::Base;
our @ISA = 'Webstellation::Request::Base';

sub run {
	my ($self, $db) = @_;
	my $name = $self->{args}->{userName};
	$self->validate('$', $name) || return { result => 'formatError', message => 'Invalid username' };
	my $players = $db->fetch('players');
	not exists $players->{$name} or return { result => 'alreadyTaken' };
	$players->{$name} = { game => undef };
	$db->write;
	return { result => 'ok' };
}

1;
