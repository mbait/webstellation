package Webstellation::Query::logout;
use strict;
use warnings;

use Webstellation::Struct::Player;

sub run {
	my ($inf, $dbi, $data) = @_;
	my $player = new Webstellation::Struct::Player $dbi;
	$player->load($data->{userName}) || return { result => $player->error };
	$player->delete;
	return { result => 'ok' };
}

1;
