package Webstellation::DBI::BerkeleyDB;

use strict;
use warnings;

use BerkeleyDB;

sub new {
	my $inf = shift;
	my $class = ref $inf || $inf;
	my $home = shift;
	print $home;
	my $env = new BerkeleyDB::Env
			-Home		=>	$home || die "database root must be specified\n",
			-ErrFile	=>	*STDERR,
			-Flags		=>	DB_CREATE or DB_INIT_CDB
		or die "cannot open enviroment: $BerkeleyDB::Error\n";
	return bless { env => $env }, $class;
}

sub dbopen {
	my ($self, $dbname) = @_;
	$self->{dbhash} = {};
	tie %{$self->{dbhash}}, 'BerkeleyDB::Hash',
			-Filename	=>	"db/$dbname.db",
			-Env		=>	$self->{env},
			-Flags		=>	DB_CREATE
		or die "cannot open database: $! $BerkeleyDB::Error\n";
	return $self->{dbhash};
}

sub dbclose {
	my $self = shift;
	untie %{$self->{dbhash}};
}

sub eraise {
	my ($self, $dbname) = @_;
	my $hash = $self->dbopen($dbname);
	%{$hash} = ();
	$self->dbclose;
}

sub hash {
	my ($self, $dbname) = @_;
	my %hash = %{$self->dbopen($dbname)};
	$self->dbclose;
	return \%hash;
}

sub keys {
	my ($self, $dbname) = @_;
	my @keys = keys %{$self->dbopen($dbname)};	
	$self->dbclose;
	return \@keys;
}

sub store {
	my ($self, $dbname, $key) = @_;
	my $hash = $self->dbopen($dbname);
	$hash->{$key} = shift;
	$self->dbclose;
}

1;
