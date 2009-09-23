package WS::Request;

use strict;
#use Tie::DB_Lock;
use Storable qw/freeze thaw/;
use DB_File;
use Data::Dumper;
use JSON::XS;

sub new {
	my $invocant = shift;
	my $class = ref($invocant) || $invocant;
	my $self = { dbfile => shift || 'data'};
	return bless $self, $class;
}

sub db_open {
	my $self = shift;
	my %dbhash;
	tie(%dbhash, 'DB_File', $self->{'dbfile'});
	$self->{'dbhash'} = \%dbhash;
}

sub db_extract {
	my $self = shift;
	for(@_) {
		if(exists $self->{'dbhash'}->{$_}) {
			$self->{$_} = thaw $self->{'dbhash'}->{$_};
		}
		push @{$self->{'dbdata'}}, $_;
	}
}

sub db_close {
	my $self = shift;
	for(@{$self->{'dbdata'}}) {
		$self->{'dbhash'}->{$_} = freeze $self->{$_};
	}
	untie %{$self->{'dbhash'}};
}

sub dispatch {
	my $self = shift;
	my $args = decode_json shift;
	$self->db_open;
	my $res;
	{
		no strict 'refs';
		$res = $args->{'action'}->($self, $args);
	}
	$self->db_close;
	return encode_json $res;
}

# Request procedures

sub register {
	my $self = shift;
	$self->db_extract(qw/players playerNames/);
	my $args = shift;
	my $players = $self->{'players'} ||= {};
	if(exists $players->{$args->{'userName'}}) {
		return { result => 'alreadyTaken' };
	}
	my $playerNames = $self->{'playerNames'} ||= [];
	push @$playerNames, $args->{'userName'}; 
	$players->{$args->{'userName'}} = $#$playerNames;
	return { result => 'OK' };
}

sub logout {
	my $self = shift;
	$self->db_extract(qw/players playerNames/);
	my $args = shift;
	my $players = $self->{'players'} ||= {};
	unless(exists $players->{$args->{'userName'}}) {
		return { result => 'unknownUser' };
	}
	my $playerNames = $self->{'playerNames'} ||= [];
	splice @$playerNames, $$players{$args->{'userName'}}, 1;
	delete $players->{$args->{'userName'}};
	return { result => 'OK' };
}

sub getUsers {
	my $self = shift;
	$self->db_extract('playerNames');
	return { users => $self->{'playerNames'}, result => 'OK' };
}

sub loadMap {
	my $self = shift;
	$self->db_extract(qw/maps mapNames/);
	my $maps = $self->{'maps'} ||= {};
	my $args = shift;
	return { result => 'mapExists' } if exists $maps->{$args->{'name'}};
	my $mapNames = $self->{'mapNames'} ||= [];
	push @$mapNames, $args->{'name'};
	$maps->{$args->{'name'}} = $#$mapNames;
	return { result => 'OK' };
}

1;
