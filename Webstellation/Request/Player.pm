package Webstellation::Request::Register;

use strict;
use warnings;

sub new {
	my $inv = shift;
	my $class = ref $inv || $inv;
	my $self;
	return bless $self, $class;
}

sub run {
	my ($self, $data) = shift;
	my $obj = Webstellation::Struct::Player->create(
		$data->{userName}) || return { result => $! };
	return { result => 'ok' };
}
