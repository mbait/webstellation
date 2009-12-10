package Webstellation::Query::clearAll;

use strict;
use warnings;

sub run {
	my ($inv, $dbi) = @_;
	$dbi->clear;
	return { result => 'ok' };
}

1;
