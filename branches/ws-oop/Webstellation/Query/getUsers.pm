package Webstellation::Query::getUsers;
use strict;
use warnings;
use Webstellation::Struct::Player;

sub run {
	my ($inv, $dbi) = @_;
	my $player = new Webstellation::Struct::Player $dbi;
	return { users => $player->keys, result => 'ok' };
}

1;
