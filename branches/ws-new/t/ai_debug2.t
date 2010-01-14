
#!/usr/bin/perl

use strict;
use lib 't';
use Test::Webstellation;

my $map = {
		  name => 'test',
          'planets' => [
                         {
                           'y' => 6,
                           'neighbors' => [
                                            11,
                                            10,
                                            4
                                          ],
                           'x' => 4,
                           'size' => 3
                         },
                         {
                           'y' => 3,
                           'neighbors' => [
                                            4,
                                            8,
                                            10,
                                            17
                                          ],
                           'x' => 9,
                           'size' => 3
                         },
                         {
                           'y' => 8,
                           'neighbors' => [
                                            6,
                                            16,
                                            15,
                                            8
                                          ],
                           'x' => 13,
                           'size' => 3
                         },
                         {
                           'y' => 11,
                           'neighbors' => [
                                            7,
                                            5,
                                            13,
                                            4,
                                            9
                                          ],
                           'x' => 7,
                           'size' => 3
                         },
                         {
                           'y' => 6,
                           'neighbors' => [
                                            1,
                                            3,
                                            7,
                                            5,
                                            8,
                                            0
                                          ],
                           'x' => 7,
                           'size' => 2
                         },
                         {
                           'y' => 9,
                           'neighbors' => [
                                            3,
                                            4
                                          ],
                           'x' => 5,
                           'size' => 2
                         },
                         {
                           'y' => 7,
                           'neighbors' => [
                                            2
                                          ],
                           'x' => 10,
                           'size' => 2
                         },
                         {
                           'y' => 9,
                           'neighbors' => [
                                            3,
                                            4,
                                            9
                                          ],
                           'x' => 9,
                           'size' => 2
                         },
                         {
                           'y' => 5,
                           'neighbors' => [
                                            1,
                                            4,
                                            2
                                          ],
                           'x' => 11,
                           'size' => 2
                         },
                         {
                           'y' => 10,
                           'neighbors' => [
                                            14,
                                            7,
                                            3
                                          ],
                           'x' => 11,
                           'size' => 2
                         },
                         {
                           'y' => 3,
                           'neighbors' => [
                                            1,
                                            0
                                          ],
                           'x' => 6,
                           'size' => 1
                         },
                         {
                           'y' => 7,
                           'neighbors' => [
                                            0,
                                            12,
                                            13
                                          ],
                           'x' => 2,
                           'size' => 1
                         },
                         {
                           'y' => 10,
                           'neighbors' => [
                                            11
                                          ],
                           'x' => 3,
                           'size' => 1
                         },
                         {
                           'y' => 13,
                           'neighbors' => [
                                            3,
                                            11
                                          ],
                           'x' => 6,
                           'size' => 1
                         },
                         {
                           'y' => 13,
                           'neighbors' => [
                                            9,
                                            15
                                          ],
                           'x' => 10,
                           'size' => 1
                         },
                         {
                           'y' => 11,
                           'neighbors' => [
                                            2,
                                            14
                                          ],
                           'x' => 13,
                           'size' => 1
                         },
                         {
                           'y' => 6,
                           'neighbors' => [
                                            2
                                          ],
                           'x' => 14,
                           'size' => 1
                         },
                         {
                           'y' => 3,
                           'neighbors' => [
                                            1
                                          ],
                           'x' => 12,
                           'size' => 1
                         }
                       ]
        };
test { action => 'clearAll' }, result => 'ok', 'clear DB';
test { action => 'uploadMap', mapInfo => $map }, result => 'ok', 'upload test';
test { action => 'register', userName => 'player1' }, result => 'ok', 'register player1';
test { action => 'createGame', userName => 'player1', gameName => 'game1', mapName => 'test', maxPlayers => 2 }, result => 'ok';
test { action => 'toggleReady', userName => 'player1' }, result => 'ok';

