package Webstellation::Request;

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
			$self->{$_} = thaw $self->{'dbhash'}->{$_} ||= {};
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
	$self->db_extract('players');
	my $args = shift;
	my $players = $self->{'players'} ||= {};
	return { result => 'alreadyTaken' } if exists $players->{$args->{'userName'}};
	$players->{$args->{'userName'}} = 0;
	return { result => 'ok' };
}

sub logout {
	my $self = shift;
	$self->db_extract('players');
	my $args = shift;
	my $players = $self->{'players'} ||= {};
	return { result => 'unknownUser' }
		unless exists $players->{$args->{'userName'}};
	delete $players->{$args->{'userName'}};
	return { result => 'ok' };
}

sub getUsers {
	my $self = shift;
	$self->db_extract('players');
	my $players = $self->{'players'};
	my @result;
	for(sort dsort keys %$players) {
		push @result, { name => $_, isReady => $players->{$_}};
	}
	return { users => \@result, result => 'ok' };
	#return { users => [sort dsort keys %$players], result => 'ok' };
}

sub uploadMap {
	my $self = shift;
	$self->db_extract('maps');
	my $maps = $self->{'maps'} ||= {};
	my $args = shift;
	return { result => 'mapExists' } if exists $maps->{$args->{'mapInfo'}->{'name'}};
	$maps->{$args->{'mapInfo'}->{'name'}} = $args->{'mapInfo'};
	return { result => 'ok' };
}

sub getMaps {
	my $self = shift;
	$self->db_extract('maps');
	my $maps = $self->{'maps'} ||= {};
	my $args = shift;
	return { maps => [sort dsort keys %$maps], result => 'ok' };
}

sub getMapInfo {
	my $self = shift;
	$self->db_extract('maps');
	my $maps = $self->{'maps'} ||= {};
	my $args = shift;
	return { result => 'unknownMap' } unless exists $maps->{$args->{'mapName'}};
	return { result => 'ok', mapInfo => $maps->{$args->{'mapName'}}};
}

sub createGame {
	my $self = shift;
	$self->db_extract(qw/games players maps/);
	my $games = $self->{'games'} ||= {};
	my $players = $self->{'players'} ||= {};
	my $maps = $self->{'maps'} ||= {};
	my $args = shift;
	return { result => 'unknownUser' } unless exists $players->{$args->{'userName'}};
	return { result => 'unknownMap' } unless exists $maps->{$args->{'mapName'}};
	return { result => 'gameExists' } if exists $games->{$args->{'gameName'}};

	$games->{$args->{'gameName'}} = {
		players => [$args->{'userName'}],
		name => $args->{'gameName'},
		map => $args->{'mapName'},
		maxPlayers => $args->{'maxPlayers'},
		status => 'preparing'
	};
	return { result => 'ok' };
}

sub joinGame {
	my $self = shift;
	$self->db_extract(qw/players games/);
	my $games = $self->{'games'};
	my $players = $self->{'players'};
	my $args = shift;
	return { result => 'unknownUser' } unless exists $players->{$args->{'userName'}};
	return { result => 'unknownGame' } unless exists $games->{$args->{'gameName'}};
	my $game = $games->{$args->{'gameName'}};
	return { result => 'alreadyMaxPlayers' } if $game->{'maxPlayers'} == length @{$game->{'players'}};
	return { result => 'alreadyStarted' } unless $game->{'state'} == 'preparing';
}

sub dsort {
	return $a cmp $b;
}

1;
