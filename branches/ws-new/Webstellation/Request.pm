package Webstellation::Request;

use strict;
#use Tie::DB_Lock;
use Storable qw/freeze thaw/;
use DB_File;
use Data::Dumper;
use JSON::XS;
use Data::Dumper;

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

sub validate {
	my ($data, $tmpl) = @_;
	if(ref $tmpl eq 'HASH') {
		ref $data eq 'HASH' || return 0;
		for(keys %$tmpl) {
			exists $data->{$_} or return 0;
			validate($data->{$_}, $tmpl->{$_}) or return 0 
		}
	}
	elsif(ref $tmpl eq 'ARRAY') {
		ref $data eq 'ARRAY' || return 0;
		for(my $i=0; $i<@$tmpl; ++$i) { 
			@$data < $i or return 0;
			validate($data->[$i], $tmpl->[$i]) or return 0 
		}
	}
	return $data ne '' && ref $data eq 'SCALAR';
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
	return encode_json { result => 'formatError', message => "$@" }
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
	my $self = shift;
	for(qw/players games maps/) {
		for my $key(keys %{$self->$_}) {
			delete $self->$_->{$key};
		}
	}
	#$self->{dbhash}->{$_} = {} for qw/players games maps/;
	#$self->$_ = {} for qw/players games maps/;
	#for(qw/players games maps/) {
	#	$self->{$_} = {} if exists $self->{$_}
	#}
	return { result => $RESULT_OK }; 
}

# User-related queries

sub register {
	my ($self, $args) = @_;
	validate $args, { userName => 'string' } or return { result => 'formatError' };
	my $player = $self->add(players => $args->{userName}) or return { result => $@ };
	$$player = { game => undef };
	return { result => $RESULT_OK };
}

sub logout {
	my ($self, $args) = @_;
	validate $args, { userName => 'string' } or return { result => 'formatError' };
	$self->delete(players => $args->{userName}) or return { result => $@ };
	return { result => $RESULT_OK };
}

sub getUsers {
	my $self = shift;
	return { result => $RESULT_OK, users => [ sort {$a cmp $b } keys %{$self->players}] };
}

sub joinGame {
	my ($self, $args) = @_;
	validate $args, { userName => 'string', gameName => 'string' } or return { result => 'formatError' };
	my ($user, $game) = ($args->{userName}, $args->{gameName});
	$self->exists(players => $user, games => $game) or return { result => $@ };
	return { result => 'alreadyInGame' } if defined $self->players->{$user}->{game};
	$game = $self->games->{$game};
	return { result => 'alreadyMaxPlayers' } if $game->{maxPlayers} == @{$game->{players}};
	return { result => 'alreadyStarted' } if $game->{status} eq 'playing';
	push @{$game->{players}}, { name => $user, isReady => 0 };	
	$self->players->{$user}->{game} = $game->{name};
	return { result => $RESULT_OK };
}

sub toggleReady {
	my ($self, $args) = @_;
	validate $args, { userName => 'string' } or return { result => 'formatError' };
	my $user = $args->{userName};
	$self->exists(players => $user) or return { result => $@ };
	return { result => 'notInGame' } unless defined $self->players->{$user}->{game};
	my $game = $self->games->{$self->players->{$user}->{game}}->{players};
	my %players = map { $_->{name} => $_ } @$game;
	++($players{$user}->{isReady} *= -1);
	return { result => $RESULT_OK };
}

sub leaveGame {
	my ($self, $args) = @_;
	validate $args, { userName => 'string' } or return { result => 'formatError' };
	my $user = $args->{userName};
	$self->exists(players => $user) or return { result => $@ };
	return { result => 'notInGame' } unless defined $self->players->{$user}->{game};
	my $game = $self->games->{$self->players->{$user}->{game}}->{players};
	$game->{players} = [ grep { ! $_->{name} eq $user } @{$game->{players}} ];
	$self->players->{$user}->{game} = undef;
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
	validate $args, { 
		userName => 'string',
	   	gameName => 'string',
	   	mapName => 'string' 
	} or return { result => 'formatError' };
	my $game = $self->add(games => $args->{gameName}) or return { result => $@ };
	unless($self->exists( players => $args->{userName}, maps => $args->{mapName})) {
		delete $self->games->{$args->{gameName}};
		return { result => $@ };
	}
	if(defined $self->players->{$args->{userName}}->{game}) { return { result => 'alreadyInGame' } }
	else { $self->players->{$args->{userName}}->{game} = $args->{gameName} }
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
	return { result => $RESULT_OK, games => [ sort {$a cmp $b} keys %{$self->games}] };
}

sub getGameInfo { 
	my ($self, $args) = @_;
	validate $args, { gameName => 'string' } or return { result => 'formatError' };
	return { result => $RESULT_OK, game => $self->games->{$args->{gameName}}};
}

sub getGameState {
	my ($self, $args) = @_;
	validate $args, { gameName => 'string' } or return { result => 'formatError' };
	return { result => $RESULT_OK, state => $self->states->{$args->{gameName}} };
}

sub loadGame {
	return { result => $RESULT_OK };
}

sub move {
	my ($self, $args) = @_;
	validate $args, { userName => 'string' } or return { result => 'formatError' };
	return { result => $RESULT_OK };
}

sub surrender {
	my ($self, $args) = @_;
	validate $args, { userName => 'string' } or return { result => 'formatError' };
	return { result => $RESULT_OK };
}
