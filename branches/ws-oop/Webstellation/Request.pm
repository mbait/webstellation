package Webstellation::Request;

use strict;
#use Tie::DB_Lock;
use Storable qw/freeze thaw/;
use DB_File;
use Data::Dumper;
use JSON;

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
		my $aa = $args->{action};
		my %h = %{*{"Webstellation::Request::"}};
		#print "$_ " for keys %h;
		if (exists $h{$aa}) {  
			$res = $args->{'action'}->($self, $args);
		}
		else {
			$res = { result => 'generalError' };
		}
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
	$players->{$args->{'userName'}} = {};
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
	return { users => [sort dsort keys %{$self->{'players'}}], result => 'ok' };
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
		players => [{ name => $args->{'userName'} }],
		name => $args->{'gameName'},
		'map' => $args->{'mapName'},
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

sub getGames {
	my $self = shift;
	$self->db_extract('games');
	return { result => 'ok', games => [sort dsort keys %{$self->{'games'}}]};
}

sub getGameInfo {
	my $self = shift;
	$self->db_extract('games');
	my $args = shift;
	return { result => 'unknownGame' } unless exists $self->{'games'}->{$args->{'gameName'}};
	return { result => 'ok', game => $self->{'games'}->{$args->{'gameName'}}};
}

sub dsort {
	return $a cmp $b;
}

1;
