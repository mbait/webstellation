#!/usr/bin/perl

use strict;
use lib 't';
use Test::Harness;

my @files1 = qw't/main.t t/map.t t/player.t t/game.t t/join.t t/validate1.t t/zhuplev1.t';
my @files2 = qw't/move.t';
#runtests @files1;
runtests @files2;
