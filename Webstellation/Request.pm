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
my ($MIN_PLANET_SIZE, $MAX_PLANET_SIZE) = (1, 3);
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
	#print "$tmpl\n";
	if(ref $tmpl eq 'HASH') {
		#print "this is hash\n";
		ref $data eq 'HASH' || return 0;
		for(keys %$tmpl) {
			#print $data->{$_}.' '.$tmpl->{$_};
			exists $data->{$_} or return 0;
			validate($data->{$_}, $tmpl->{$_}) or return 0 
		}
		return 1;
	}
	elsif(ref $tmpl eq 'ARRAY') {
		#print "this is array\n";
		ref $data eq 'ARRAY' || return 0;
		for my $elem (@$tmpl) {
			#@$data or return 0;
			validate($_, $elem) or return 0 for(@$data);
		}
		return 1;
	}
	else {
		#print $tmpl;
		return 0 if ref $data;
		return $data =~ /^-?\d+$/ if $tmpl eq 'int';
		#return ($data >= $1 && $data <= $2) if $tmpl =~ /(\d+)..(\d+)/;
		return $data ne '';
	}
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
	return encode_json { result => 'formatError', message => 'Action is undefined' }
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

sub clearAll {
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
	# and all his games too 
	# warning !!! this is temporary code and it must be removed
	# as soon as possible
	for(keys %{$self->games}) { 
		my %users = map { $_->{name} => 0 } @{$self->games->{$_}->{players}};
		delete $self->games->{$_} if exists $users{$args->{userName}};
	}
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
	my $game = $self->games->{$self->players->{$user}->{game}};
	my %players = map { $_->{name} => $_->{isReady} } @{$game->{players}};
	++($players{$user} *= -1);
	my $all = 1;
	for(@{$game->{players}}) {
		$_->{isReady} = $players{$_->{name}};
		$all &&= $players{$_->{name}};
	}
	if($all && @{$game->{players}} > 1) {
		$game->{status} = 'playing';
		my $state = $self->states->{$game->{name}} = { active => 0, planets => [], score => [] };
		push @{$state->{planets}}, { bases => 0, owner => undef } for @{$self->maps->{$game->{'map'}}->{planets}};
		push @{$state->{score}}, { planets => 0, bases => 0, influence => 0 } for @{$game->{players}};
	}
	
	return { result => $RESULT_OK };
}

sub leaveGame {
	my ($self, $args) = @_;
	validate $args, { userName => 'string' } or return { result => 'formatError' };
	my $user = $args->{userName};
	$self->exists(players => $user) or return { result => $@ };
	return { result => 'notInGame' } unless defined $self->players->{$user}->{game};
	my $players = $self->games->{$self->players->{$user}->{game}}->{players};
	@$players = grep { $_->{name} ne $user } @$players;
	$self->players->{$user}->{game} = undef;
	return { result => $RESULT_OK };
}

# Map-related queries

sub uploadMap {
	my ($self, $args) = @_;
	validate $args, { 
		mapInfo => { 
			name => 'string', 
			planets => [{ 
				x => 'int',
			   	y => 'int',
				size => 'int',
			   	neighbors => [] 
			}] 
		}
   	} or return { result => 'formatError' };
	
	my $map = $self->add(maps => $args->{mapInfo}->{name}) or return { result => $@ };
	unless(eval {
		my $planetcnt = @{$args->{mapInfo}->{planets}};
		my $planetindex = 0;
		for(@{$args->{mapInfo}->{planets}}) {
			my $size = $_->{size};
			die unless ($size >= $MIN_PLANET_SIZE && $size <= $MAX_PLANET_SIZE);
			for(@{$_->{neighbors}}) {
				die unless $_ <= $planetcnt && $_ >= 0; 
				die if $_ == $planetindex;
			}
			++$planetindex;
		}
		1;
	}) {
		delete $self->{maps}->{$args->{mapInfo}->{name}};
		return { result => 'badMapInfo' } 
	}
	$$map = $args->{mapInfo};
	return { result => $RESULT_OK };
}

sub getMaps {
	my $self = shift;
	return { result => $RESULT_OK, maps => [ sort {$a cmp $b} keys %{$self->maps}] };
}

sub getMapInfo {
	my ($self, $args) = @_;
	validate $args, { mapName => 'string' } or return { result => 'formatError' };
	$self->exists(maps => $args->{mapName}) or return { result => $@ };
	return { result => $RESULT_OK, 'map' => $self->maps->{$args->{mapName}}};
}

# Game-related queries

sub createGame {
	my ($self, $args) = @_;
	validate $args, { 
		userName => 'string',
	   	gameName => 'string',
	   	mapName => 'string', 
		maxPlayers => 'int'
	} or return { result => 'formatError' };
	return { result => $unique_error{games} } if $self->exists(games => $args->{gameName});
	return { result => $@ } unless $self->exists( players => $args->{userName}, maps => $args->{mapName});
	return { result => 'badMaxPlayers' } unless
		$args->{maxPlayers} >= $MIN_PLAYERS && $args->{maxPlayers} <= $MAX_PLAYERS; 
	if(defined $self->players->{$args->{userName}}->{game}) { return { result => 'alreadyInGame' } };

	my $game = $self->add(games => $args->{gameName});
	$$game = {
		name	=>	$args->{gameName},
		'map'	=>	$args->{mapName},
		maxPlayers	=>	$args->{maxPlayers},
		players		=>	[{ name => $args->{userName}, isReady => 0 }],
		status		=>	'preparing'
	};
	$self->players->{$args->{userName}}->{game} = $args->{gameName};
	return { result => $RESULT_OK };
}

sub getGames {
	my $self = shift;
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
	$self->games->{$args->{gameName}}->{status} eq 'playing' or return { result => 'notStarted' };
	return { result => $RESULT_OK, game => $self->states->{$args->{gameName}} };
}

sub loadGame {
	return { result => $RESULT_OK };
}

sub move {
	my ($self, $args) = @_;
	validate $args, { userName => 'string', planet => 'int' } or return { result => 'formatError' };
	# check user
	$self->exists(players => $args->{userName}) or return { result => 'notInGame' };
	defined	$self->games->{$self->players->{$args->{userName}}->{game}} or return { result => 'notInGame' };
	my $game = $self->games->{$self->players->{$args->{userName}}->{game}};
	# check game status
	$game->{status} eq 'playing' or return { result => 'notStarted' };
	# check turn order
	my $i = 0;
	my %players = map { $_->{name} => $i++ } @{$game->{players}};
	my $state = $self->states->{$game->{name}};
	$state->{active} == $players{$args->{userName}} or return { result => 'notYourTurn' };
	# check planet index
	my $map = $self->maps->{$game->{'map'}};	
	@{$map->{planets}} > $args->{planet} or return { result => 'badPlanet' };

	my $planet = $state->{planets}->[$args->{planet}];
	my $player = $args->{userName};
	return { result => 'badPlanet' } if 
		defined $planet->{owner} && $planet->{owner} != $state->{active} && $planet->{bases} || 
		$planet->{bases} == $map->{planets}->[$args->{planet}]->{size};
	$planet->{owner} = $state->{active};
	++$planet->{bases};
	# calculate influence
	my @changed;
	do {
		@changed = ();
		my $index = 0;
		for my $p(@{$state->{planets}}) {
			my %inf;
		   	%inf = ( $p->{owner} => $p->{bases} ) if defined $p->{owner} && $p->{bases};
			for(map { $state->{planets}->[$_] } @{$map->{planets}->[$index]->{neighbors}}) {
				 $inf{$_->{owner}} += $_->{bases} if defined $_->{owner} && $_->{bases};
			}
			unless( %inf ) {
				$p->{owner} = undef;
				$p->{bases} = 0;
			}
			my @max = reverse sort { $inf{$a} <=> $inf{$b} } keys %inf; 
			@max = grep { $inf{$_} > $inf{$p->{owner}} } @max if defined $p->{owner} && $p->{bases};
			#print Dumper { %inf };
			#print Dumper [ @max ];
			if(@max) {
				my ($new, $new2) = @max;
				$new = undef if defined $new2 && $inf{$new} == $inf{$new2};
				print "DEBUG, planet: $index\n";
				print Dumper \$new;
				push @changed, { ind => $index, owner => $new } if $new ne $p->{owner};
				print Dumper \@changed;
			}
			++$index;
		}
		for(@changed) {
			my $p = $state->{planets}->[$_->{ind}];
			$p->{owner} = $_->{owner};
			$p->{bases} = 0;
		}
	}while(@changed);

	# calculate state
	for my $field (@{$state->{score}}) {
		$field->{$_} = 0 for qw/planets bases influence/;
	}
	for(my $i=0; $i<@{$state->{planets}}; ++$i) {
		my $planet = $state->{planets}->[$i];
		if(defined $planet->{owner}) {
			my $score = $state->{score}->[$planet->{owner}];
			++$score->{planets};
			$score->{bases} += $planet->{bases};
		}
	}
	$state->{active} = ($state->{active} + 1) % @{$game->{players}};

	return { result => $RESULT_OK };
}

sub surrender {
	my ($self, $args) = @_;
	validate $args, { userName => 'string' } or return { result => 'formatError' };
	return { result => $RESULT_OK };
}
