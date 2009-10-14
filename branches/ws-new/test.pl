#!/usr/bin/perl

use strict;
use lib 't';
use Test::Harness;

my @files1 = qw't/main.t t/map.t t/player.t t/game.t t/join.t';
my @files2 = qw't/validate1.t';
#runtests @files1;
runtests @files2;
