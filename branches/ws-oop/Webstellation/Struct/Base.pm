package Webstellation::Struct::Base;
use strict;
use warnings;
use Storable	qw/thaw freeze/;
use Data::Dumper;

sub insert {
	my ($self, $key) = @_;
	my $t = $self->{dbi}->hash($self->{dbname});
	if(exists $t->{$key}) {
		$self->{error} = $self->{insert_error};
		return;
	}
	return 1;
}

sub load {
	my ($self, $key) = @_;
	my $t = $self->{dbi}->hash($self->{dbname});
	unless(exists $t->{$key}) {
		$self->{error} = $self->{load_error};
		return;
	}
	$self->{data} = thaw $t->{$key};
	return 1;
}

sub delete {
	my $self = shift;
	my $key = $self->{data}->{$self->{keyfield}};
	$self->{dbi}->delete($self->{dbname}, $key);
}

sub init {
	my $self = shift;
	$self->{data} = {};
	{
		no strict 'refs';
		no warnings;
		for my $field(keys %{$self->{fields}}) {
			my $slot = $self->{pkgname}."::$field";
			*$slot = sub {
				my $self = shift;
				if(@_) { return ($self->{data}->{$field} = shift) }
				else { return $self->{data}->{$field} }
			}
		}
	}
}

sub commit {
	my $self = shift;
	my $key = $self->{data}->{$self->{keyfield}};
	$self->{dbi}->store($self->{dbname}, $key, freeze $self->{data});
}

sub keys {
	my $self = shift;
	return [ sort { $a cmp $b } @{$self->{dbi}->keys($self->{dbname})} ];
}

sub clear_db {
	my $self = shift;
	$self->{dbi}->eraise($self->{dbname});
}


sub error {
	my $self = shift;
	return $self->{error} || 'no error';
}

1;
