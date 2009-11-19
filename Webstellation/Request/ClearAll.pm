package Webstellation::Request::ClearAll;

use strict;
use warnings;

use Webstellation::Request::Base;
our @ISA = 'Webstellation::Request::Base';

sub run {
	my ($self, $db) = @_;
	$db->write(map { $_ => {} } qw/users maps games states/);
	return { result => 'ok' };
}

1;
