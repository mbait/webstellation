package Webstellation::Query::clearAll;

use strict;
use warnings;

use base 'Webstellation::Query::Base';

sub run {
	my ($inv, $dbi) = @_;
	$dbi->clear;
	return { result => 'ok' };
}

1;
