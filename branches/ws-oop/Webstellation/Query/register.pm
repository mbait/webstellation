package Webstellation::Query::register;
use strict;
use warnings;
use Webstellation::Struct::Player;

sub run {
	my ($inv, $dbi, $data) = @_;
	my $player = new Webstellation::Struct::Player $dbi;
	$player->insert($data->{userName}) || return { result => $player->error };
	$player->name($data->{userName});
	$player->commit;
	return { result => 'ok' };
}

1;
