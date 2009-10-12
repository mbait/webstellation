#!/usr/bin/perl

use strict;
use Test::Webstellation;

test { action => 'clear' }, result => 'ok', 'clear databse';
test { action => 'getMaps' }, maps => [], 'empty list of maps', 'is_deeply';
my $aldebaran =  {
	name => 'Aldebaran', 
	planets => [
		{ x => 0, y => 0, size => 3, neighbors => [1] },
		{ x => 1, y => 0, size => 1, neighbors => [2] },
		{ x => 0, y => 1, size => 1, neighbors => [0] },
	]
};
test { action => 'uploadMap', mapInfo => $aldebaran }, result => 'ok', 'upload Aldebaran';
my $ngc2238 = {
	name => 'NGC 2238', 
	planets => [
		{ x => 0, y => 0, size => 3, neighbors => [] },
		{ x => 1, y => 0, size => 1, neighbors => [] },
		{ x => 0, y => 1, size => 1, neighbors => [] },
	]	
};
test { action => 'uploadMap', mapInfo => $ngc2238 }, result => 'ok', 'upload NGC 2238';
my $betelgeuse = {
	name => 'Betelgeuse', 
	planets => [
		{ x => 0, y => 0, size => 3, neighbors => [] },
		{ x => 1, y => 0, size => 1, neighbors => [] },
		{ x => 0, y => 1, size => 1, neighbors => [] },
	]	
};
test { action => 'uploadMap', mapInfo => $betelgeuse	}, result =>, 'ok', 'upload Betelgeuse';
my $cassiopeia = {
	name => 'Cassiopeia', 
	planets => [
		{ x => 0, y => 0, size => 3, neighbors => [] },
		{ x => 1, y => 0, size => 1, neighbors => [] },
		{ x => 0, y => 1, size => 1, neighbors => [] },
	]	
};
test { action => 'uploadMap', mapInfo => $cassiopeia	}, result => 'ok', 'upload Cassiopeia';
test { action => 'uploadMap', mapInfo => $cassiopeia	}, result => 'mapExists', 'upload Cassiopeia again';
test { action => 'getMaps' }, maps => ['Aldebaran', 'Betelgeuse', 'Cassiopeia', 'NGC 2238'], 'getMaps', 'is_deeply';
test { action => 'getMapInfo', mapName => 'Cassiopeia' }, 'map' => $cassiopeia, 'getMapInfo', 'is_deeply'; 


