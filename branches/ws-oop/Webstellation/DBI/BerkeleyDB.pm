package Webstellation::DBI::BerkeleyDB;

use strict;
use warnings;

use BerkeleyDB;

sub new {
	my $inf = shift;
	my $class = ref $inf || $inf;
	my $env = new BerkeleyDB::Env
			-Home		=>	shift || die "database root must be specified\n",
			-ErrFile	=>	*STDERR,
			-Flags		=>	DB_CREATE or DB_INIT_CDB
		or die "cannot open enviroment: $BerkeleyDB::Error\n";
	return bless { env => $env }, $class;
}

sub clear {
	my $self = shift;
	$self->{cleared} = {};
	$self->{clear} = 1;
}

1;
