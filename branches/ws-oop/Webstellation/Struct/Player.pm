package Webstellation::Struct::Player;

use strict;
use warnings;

use Class::Struct name => '$', game => '*Webstellation::Struct::Game', isReady => '$';

our @ISA = qw/Webstellation::Struct/;

sub create_error { return 'alreadyTaken' }
sub load_error { return 'unknownUser' } 



1;
