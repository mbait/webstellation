package Webstellation::DBI::BerkeleyDB;

use strict;
use warnings;

use BerkeleyDB;

sub new {
	my ($inv, $home) = @_;
	my $class = ref $inv || $inv;
	my $env = new BerkeleyDB::Env
			-Home		=>	$home,
			-Flags		=>	DB_CREATE | DB_INIT_CDB | DB_INIT_MPOOL
		or die "cannot open enviroment: $BerkeleyDB::Error\n";
	return bless { env => $env }, $class;
}

sub dbopen {
	my ($self, $dbname) = @_;
	$self->{dbhash} = {};
	$self->{db} = tie %{$self->{dbhash}}, 'BerkeleyDB::Hash',
			-Filename	=>	"$dbname.db",
			-Env		=>	$self->{env},
			-Flags		=>	DB_CREATE
		or die "cannot open database: $BerkeleyDB::Error\n";
	return $self->{dbhash};
}

sub dbclose {
	my $self = shift;
	delete $self->{db};
	untie %{$self->{dbhash}};
}

sub eraise {
	my ($self, $dbname) = @_;
	$self->dbopen($dbname);
	my $cnt;
	BerkeleyDB::Common::truncate($self->{db}, \$cnt);
	$self->dbclose();
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
	my ($self, $dbname, $key, $data) = @_;
	my $hash = $self->dbopen($dbname);
	my $lk = $self->{db}->cds_lock();
	$hash->{$key} = $data;
	$lk->cds_unlock;
	undef $lk;
	$self->dbclose;
}

sub delete {
	my ($self, $dbname, $key) = @_;
	my $hash = $self->dbopen($dbname);
	delete $hash->{$key};
	$self->dbclose;
}

1;
