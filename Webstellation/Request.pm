package Webstellation::Request;

use strict;
#use Tie::DB_Lock;
use Storable qw/freeze thaw/;
use DB_File;
use Data::Dumper;
use JSON::XS;

my $RESULT_OK = 'ok';
my ($MIN_PLAYERS, $MAX_PLAYERS) = (2, 10);
my %unique_error = (
	games => 'gameExists',
	players	=> 'alreadyTaken',
	maps => 'mapExists' 
);
my %exists_error = (
	games => 'unknownGame',
	maps => 'unknownMap',
	players => 'unknownUser'
);

sub mysort {
	die;
	return sort {$a cmp $b} shift;
}

sub new {
	my $invocant = shift;
	my $class = ref($invocant) || $invocant;

	die "Database file must be specified!" unless @_;
	my $self = { dbfile => shift };
	return bless $self, $class;
}

sub AUTOLOAD : lvalue {
	my $self = shift;
	my ($name) = reverse split /::/, our $AUTOLOAD;
	return $self if $name eq 'DESTROY';
	
	unless (exists $self->{$name}) {
		push @{$self->{dbdata}}, $name; 
		if(exists $self->{dbhash}->{$name}) { $self->{$name} = thaw $self->{dbhash}->{$name} }
		else { $self->{$name} = {} }
	}
	return $self->{$name};
}

sub exists {
	my ($self, %values) = @_;
	for(keys %values) {
		unless(exists $self->$_->{$values{$_}}) {
			$@ = $exists_error{$_};
			return 0;
		}
	}
	return 1;
}

sub add {
	my ($self, %args) = @_;
	my @result;
	for(keys %args) {
		if(exists $self->$_->{$args{$_}}) {
			$@ = $unique_error{$_};
			return undef;
		}
		push @result, \($self->$_->{$args{$_}} = undef);
	}
	if(scalar @result > 1) { return @result; }
	else { return shift @result; }
}

sub delete {
	my ($self, %values) = @_;
	for(keys %values) {
		unless (exists $self->$_->{$values{$_}}) {
			$@ = $exists_error{$_};
			return 0;
		}
		delete $self->$_->{$values{$_}};
	}
	return 1;
}

sub dispatch { 
	my ($self, $data) = @_;
	return encode_json { result => 'generalError', message => "$@" }
		unless eval { $data = decode_json $data };
	return encode_json { result => 'generalError', message => 'Action is undefined' }
		unless exists $data->{action};

	my %dbhash;
	tie %dbhash, 'DB_File', $self->{dbfile} or die $@;
	$self->{dbhash} = \%dbhash;
	$self->{dbdata} = ();
	my $result;
	{
		no strict 'refs';
		$result = $data->{action}->($self, $data);
	}
	$dbhash{$_} = freeze $self->{$_} for @{$self->{dbdata}};
	untie %dbhash;
	return encode_json $result;
}

# Request methods

sub clear {
	no strict 'refs';
	my $self = shift;
	#$self->{dbhash}->{$_} = {} for qw/players games maps/;
	return { result => $RESULT_OK }; 
}

# User-related queries

sub register {
	my ($self, $args) = @_;
	my $player = $self->add(players => $args->{userName}) or return { result => $@ };
	$$player = { isReady => 0 };
	return { result => $RESULT_OK };
}

sub logout {
	my ($self, $args) = @_;
	$self->delete(players => $args->{userName}) or return { result => $@ };
	return { result => $RESULT_OK };
}

sub getUsers {
	my $self = shift;
	return { result => $RESULT_OK, users => [ sort {$a cmp $b } keys %{$self->players}] };
}

sub joinGame {
	return { result => $RESULT_OK };
}

sub toggleReady {
	return { result => $RESULT_OK };
}

sub leaveGame {
	return { result => $RESULT_OK };
}

# Map-related queries

sub uploadMap {
	my ($self, $args) = @_;
	my $map = $self->add(maps => $args->{mapInfo}->{name}) or return { result => $@ };
	$$map = $args->{mapInfo};
	return { result => $RESULT_OK };
}

sub getMaps {
	my $self = shift;
	return { result => $RESULT_OK, maps => [ sort {$a cmp $b} keys %{$self->maps}] };
}

sub getMapInfo {
	my ($self, $args) = @_;
	$self->exists(maps => $args->{mapName}) or return { result => $@ };
	return { result => $RESULT_OK, 'map' => $self->maps->{$args->{mapName}}};
}

# Game-related queries

sub createGame {
	my ($self, $args) = @_;
	$self->exists(
	   	players => $args->{userName},
	   	maps => $args->{mapName}
	) or return { result => $@ };
	my $game = $self->add(games => $args->{gameName}) or return { result => $@ };
	$$game = {
		name	=>	$args->{gameName},
		'map'	=>	$args->{mapName},
		maxPlayers	=>	$args->{maxPlayers},
		players		=>	[{ name => $args->{userName}, isReady => 0 }],
		status		=>	'preparing'
	};
	return { result => $RESULT_OK };
}

sub getGames {
	my $self = shift;
	#print mysort keys %{$self->games};
	return { result => $RESULT_OK, games => [ keys %{$self->games}] };
}

sub getGameInfo { 
	return { result => $RESULT_OK };
}

sub getGameState {
	return { result => $RESULT_OK };
}

sub loadGame {
	return { result => $RESULT_OK };
}

sub move {
	return { result => $RESULT_OK };
}

sub surrender {
	return { result => $RESULT_OK };
}
