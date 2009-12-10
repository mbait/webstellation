package Webstellation::Struct::Base;
use strict;
use warnings;
use Storable	qw/thaw freeze/;

sub insert {
	my ($self, $key) = @_;
	my $t = $self->{dbi}->hash($self->{dbname});
	return { result => $self->{insert_error} || die 'Value exists' } if
		exists $t->{$key};
	return { result => 'ok' };
}

sub init {
	my $self = shift;
	{
		no strict 'refs';
		no warnings;
		for my $field(keys %{$self->{fields}}) {
			my $slot = $self->{pkgname}."::$field";
			*$slot = sub {
				my $self = shift;
				if(@_) { return $self->{$field} = shift }
				else { return $self->{$field } }
			}
		}
	}
}

sub commit {
	my $self = shift;
	my %hash = map { $_ => $self->{$_} } keys %{$self->{fields}};
	my $key = $self->{$self->{keyfield}};
	$self->{dbi}->store($self->{dbname}, $key, freeze \%hash);
}

sub keys {
	my $self = shift;
	return [ sort { $a cmp $b } @{$self->{dbi}->keys($self->{dbname})} ];
}

sub clear_db {
	my $self = shift;
	$self->{dbi}->eraise($self->{dbname});
}

1;
