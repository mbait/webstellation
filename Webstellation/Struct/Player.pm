package Webstellation::Struct::Player;
use strict;
use warnings;
use base 'Webstellation::Struct::Base';

sub new {
	my ($inv, $dbi) = @_;
	my $class = ref $inv || $inv;
	my $self = {
			dbi				=>	$dbi,
			dbname			=>	'players',
			keyfield		=>	'name',
			fields			=>	{ name => '$', game => '$' },
			pkgname			=>	__PACKAGE__,
			insert_error	=>	'alreadyTaken',
			load_eror		=>	'unknownUser',
		};
	bless $self, $class;
	$self->init;
	return $self;
}

1;
