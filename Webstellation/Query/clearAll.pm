package Webstellation::Query::clearAll;

use strict;
use warnings;

use Webstellation::Struct::Player;

sub run {
	my ($inv, $dbi) = @_;
	my $player = new Webstellation::Struct::Player $dbi;
	$player->clear_db;
	return { result => 'ok' };
}

1;
