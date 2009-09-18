#!/usr/bin/perl -w

use strict;
use JSON::XS;

use Request;

sub	response {
	my $var = decode_json $_[0];
	my $act = $var->{'request'};
    $act Request $var;	
}

response encode_json { request => 'register' };
