use strict;
use lib 't';
use Test::Webstellation;

test { action => "clear" }, result => "ok", "Clearing database. Required first command.", 'is_deeply';

test ' incorrectJSON *ROFL* ', result => "formatError", "incorrectJSON", 'is_deeply';

test { }, result => "formatError", "Empty JSON", 'is_deeply';

test { leftField => "leftValue" }, result => "formatError", "JSON without action field", 'is_deeply';

test { action => "uploadMap" }, result => "formatError", "uploadMap without mapInfo field", 'is_deeply';

test { action => "uploadMap", mapInfo => 1 }, result => "formatError", "uploadMap: mapInfo is integer", 'is_deeply';

test { action => "uploadMap", mapInfo => [] }, result => "formatError", "uploadMap: mapInfo is array", 'is_deeply';

test { action => "uploadMap", mapInfo => {} }, result => "formatError", "uploadMap: mapInfo is empty structure", 'is_deeply';

test { action => "uploadMap", mapInfo => {planets => [], name => "map"} }, result => "ok", "uploadMap: correct map name, planets is empry array", 'is_deeply';

test { action => "uploadMap", mapInfo => {planets => [], name => ""} }, result => "formatError", "uploadMap: map name is empty, planets is empry array", 'is_deeply';

test { action => "uploadMap", mapInfo => {planets => [], name => []} }, result => "formatError", "uploadMap: map is empty array, planets is empry array", 'is_deeply';

test { action => "uploadMap", mapInfo => {planets => [], name => {}} }, result => "formatError", "uploadMap: map is empty structure, planets is empry array", 'is_deeply';

test { action => "uploadMap", mapInfo => {planets => [{}], name => "map"} }, result => "formatError", "uploadMap: planets is empty structure", 'is_deeply';

test { action => "uploadMap", mapInfo => {planets => [{}, {}, {}], name => "map"} }, result => "formatError", "uploadMap: planets are three empty structures", 'is_deeply';

test { action => "uploadMap", mapInfo => {planets => [{y => 1, x => 1, size => 1}], name => "map"} }, result => "formatError", "uploadMap: planet without neighbors", 'is_deeply';

test { action => "uploadMap", mapInfo => {planets => [{y => 1, neighbors => 1, x => 1, size => 1}], name => "map"} }, result => "formatError", "uploadMap: planet neighbors is number", 'is_deeply';

test { action => "uploadMap", mapInfo => {planets => [{y => 1, neighbors => "string", x => 1, size => 1}], name => "map"} }, result => "formatError", "uploadMap: planet neighbors is string", 'is_deeply';

test { action => "uploadMap", mapInfo => {planets => [{y => 1, neighbors => {}, x => 1, size => 1}], name => "map"} }, result => "formatError", "uploadMap: planet neighbors is empty structure", 'is_deeply';

test { action => "uploadMap", mapInfo => {planets => [{y => 1, neighbors => [1], x => 1, size => 1}, {y => 2, neighbors => [0], x => 2, size => 3}], name => "new_map_2_planets"} }, result => "ok", "uploadMap", 'is_deeply';

test { action => "uploadMap", mapInfo => {planets => [{y => 1, neighbors => [], x => 1, size => 1}], name => "new_map"} }, result => "ok", "uploadMap: planet neighbors is empty array", 'is_deeply';

test { action => "uploadMap", mapInfo => {planets => [{y => 1, neighbors => [0, 25], x => 1, size => 1}], name => "new_map"} }, result => "mapExists", "uploadMap: map already exists", 'is_deeply';

test { action => "uploadMap", mapInfo => {planets => [{y => 1, neighbors => [-1], x => 1, size => 1}], name => "new_map"} }, result => "mapExists", "uploadMap: map already exists", 'is_deeply';

test { action => "uploadMap", mapInfo => {planets => [{y => 1, neighbors => [1, 0], x => 1, size => 1}, {y => 3, neighbors => [0], x => 3, size => 2}], name => "new_map"} }, result => "mapExists", "uploadMap: map already exists", 'is_deeply';

test { action => "uploadMap", mapInfo => {planets => [{y => 1, neighbors => [], x => 1, size => 1}, {y => 1, neighbors => [], x => 1, size => 2}], name => "new_map"} }, result => "mapExists", "uploadMap: map already exists", 'is_deeply';

test { action => "uploadMap", mapInfo => {planets => [{y => 1, neighbors => [0, 25], x => 1, size => 1}], name => "new_map1"} }, result => "badMapInfo", "uploadMap: one of planet neighbors is more than their number", 'is_deeply';

test { action => "uploadMap", mapInfo => {planets => [{y => 1, neighbors => [-1], x => 1, size => 1}], name => "new_map1"} }, result => "badMapInfo", "uploadMap: one of planet neighbors is negative", 'is_deeply';

test { action => "uploadMap", mapInfo => {planets => [{y => 1, neighbors => [1, 0], x => 1, size => 1}, {y => 3, neighbors => [0], x => 3, size => 2}], name => "new_map1"} }, result => "badMapInfo", "uploadMap: there's meshes in graph", 'is_deeply';

#test { action => "uploadMap", mapInfo => {planets => [{y => 1, neighbors => [], x => 1, size => 1}, {y => 1, neighbors => [], x => 1, size => 2}], name => "unique_map_name. Because Sasha was crying ;)"} }, result => "badMapInfo", "uploadMap: planets coordinates are equal", 'is_deeply';

test { action => "uploadMap", mapInfo => {planets => [{y => 1, neighbors => [], x => "ababaca", size => 1}], name => "new_map"} }, result => "formatError", "uploadMap: planet x coordinate is string", 'is_deeply';

test { action => "uploadMap", mapInfo => {planets => [{y => [], neighbors => [], x => 1, size => 1}], name => "new_map"} }, result => "formatError", "uploadMap: planet y coordinate is empty array", 'is_deeply';

test { action => "uploadMap", mapInfo => {planets => [{y => {}, neighbors => [], x => 1, size => 1}], name => "new_map"} }, result => "formatError", "uploadMap: planet y coordinate is empty structure", 'is_deeply';

test { action => "uploadMap", mapInfo => {planets => [{y => 1, neighbors => [], x => 1, size => -2}], name => "new_map"} }, result => "mapExists", "uploadMap: map already exists", 'is_deeply';

test { action => "uploadMap", mapInfo => {planets => [{y => 1, neighbors => [], x => 1, size => 0}], name => "new_map"} }, result => "mapExists", "uploadMap: map already exists", 'is_deeply';

test { action => "uploadMap", mapInfo => {planets => [{y => 1, neighbors => [], x => 1, size => 125}], name => "new_map"} }, result => "mapExists", "uploadMap: map already exists", 'is_deeply';

test { action => "uploadMap", mapInfo => {planets => [{y => 1, neighbors => [], x => 1, size => -2}], name => "new_map1"} }, result => "badMapInfo", "uploadMap: planet size is negative", 'is_deeply';

test { action => "uploadMap", mapInfo => {planets => [{y => 1, neighbors => [], x => 1, size => 0}], name => "new_map1"} }, result => "badMapInfo", "uploadMap: planet size is zero", 'is_deeply';

test { action => "uploadMap", mapInfo => {planets => [{y => 1, neighbors => [], x => 1, size => 125}], name => "new_map1"} }, result => "badMapInfo", "uploadMap: planet size is more than 3", 'is_deeply';

#test { action => "uploadMap", mapInfo => {planets => [{y => 1, neighbors => [], x => 1, size => 2}, {y => 2, neighbors => [0], x => 2, size => 3}], name => "new_map1"} }, result => "badMapInfo", "uploadMap: planets graph is non undirected", 'is_deeply';

test { action => "uploadMap", mapInfo => {planets => [{y => 1, neighbors => [], x => 1, size => 2}, {y => 2, neighbors => [0], x => 2, size => 3}], name => "new_map"} }, result => "mapExists", "uploadMap: map already exists", 'is_deeply';

test { action => "uploadMap", mapInfo => {planets => [{y => 1, neighbors => [1], x => 1, size => 2}, {y => 2, neighbors => [0], x => 2, size => 3}, {y => 4, neighbors => [3], x => 4, size => 2}, {y => 6, neighbors => [2], x => 6, size => 3}], name => "new_map1_ok"} }, result => "ok", "uploadMap", 'is_deeply';

#test { action => "uploadMap", mapInfo => {planets => [{y => 1, neighbors => [1], x => 1, size => 2}, {y => 2, neighbors => [0], x => 2, size => 3}, {y => 4, neighbors => [3], x => 4, size => 2}, {y => 6, neighbors => [2, 1], x => 6, size => 3}], name => "new_map1"} }, result => "badMapInfo", "uploadMap: planets graph is non undirected", 'is_deeply';

test { action => "uploadMap", mapInfo => {planets => [{y => 1, neighbors => [1], x => 1, size => 2}, {y => 2, neighbors => [0], x => 2, size => 3}, {y => 4, neighbors => [3], x => 4, size => 2}, {y => 6, neighbors => [2, 1], x => 6, size => 3}], name => "new_map"} }, result => "mapExists", "uploadMap: map already exists", 'is_deeply';

test { action => "uploadMap", mapInfo => {planets => [{y => 1, neighbors => [], x => 1, size => "1.5"}], name => "new_map"} }, result => "formatError", "uploadMap: planet size is double", 'is_deeply';

test { action => "getMapInfo" }, result => "formatError", "getMapInfo without mapName", 'is_deeply';

test { mapName => [], action => "getMapInfo" }, result => "formatError", "getMapInfo: mapName is empty array", 'is_deeply';

test { mapName => {}, action => "getMapInfo" }, result => "formatError", "getMapInfo: mapName is empty structure", 'is_deeply';

test { action => "register" }, result => "formatError", "register without userName", 'is_deeply';

test { action => "register", userName => [] }, result => "formatError", "register: userName is empty array", 'is_deeply';

test { action => "register", userName => {} }, result => "formatError", "register: userName is empty structure", 'is_deeply';

test { action => "register", userName => "vasya" }, result => "ok", "register: all data is valid", 'is_deeply';

test { action => "joinGame", userName => "vasya" }, result => "formatError", "joinGame without userName and gameName", 'is_deeply';

test { action => "joinGame", userName => "vasya" }, result => "formatError", "joinGame without gameName, but user exists", 'is_deeply';

test { action => "joinGame", userName => "qwe" }, result => "formatError", "joinGame without gameName, but user doesn't exist", 'is_deeply';

test { action => "joinGame", userName => "vasya", gameName => [] }, result => "formatError", "joinGame: gameName is empty array, but user exists", 'is_deeply';

test { action => "joinGame", userName => "qwe", gameName => {} }, result => "formatError", "joinGame: gameName is empty structure, but user doesn't exist", 'is_deeply';

test { action => "toggleReady" }, result => "formatError", "toggleReady without userName", 'is_deeply';

test { action => "toggleReady", userName => [] }, result => "formatError", "toggleReady: userName is empty array", 'is_deeply';

test { action => "toggleReady", userName => {} }, result => "formatError", "toggleReady: userName is empty structure", 'is_deeply';

test { action => "leaveGame" }, result => "formatError", "leaveGame without userName", 'is_deeply';

test { action => "leaveGame", userName => [] }, result => "formatError", "leaveGame: userName is empty array", 'is_deeply';

test { action => "leaveGame", userName => {} }, result => "formatError", "leaveGame: userName is empty structure", 'is_deeply';

test { action => "logout" }, result => "formatError", "logout without userName", 'is_deeply';

test { action => "logout", userName => [] }, result => "formatError", "logout: userName is empty array", 'is_deeply';

test { action => "logout", userName => {} }, result => "formatError", "logout: userName is empty structure", 'is_deeply';

test { maxPlayers => 1, mapName => "name", action => "createGame", userName => "name" }, result => "formatError", "createGame without gameName", 'is_deeply';

test { maxPlayers => 1, mapName => "name", action => "createGame", gameName => "name" }, result => "formatError", "createGame without userName", 'is_deeply';

test { maxPlayers => 1, action => "createGame", userName => "name", gameName => "name" }, result => "formatError", "createGame without mapName", 'is_deeply';

test { mapName => "name", action => "createGame", userName => "name", gameName => "name" }, result => "formatError", "createGame without maxPlayers", 'is_deeply';

test { maxPlayers => 1, mapName => "name", action => "createGame", userName => "name", gameName => {} }, result => "formatError", "createGame: gameName is empty structure", 'is_deeply';

test { maxPlayers => 1, mapName => [], action => "createGame", userName => "name", gameName => "name" }, result => "formatError", "createGame: mapName is empty array", 'is_deeply';

test { maxPlayers => "string", mapName => "name", action => "createGame", userName => "name", gameName => "name" }, result => "formatError", "createGame: maxPlayers is string", 'is_deeply';

test { maxPlayers => {}, mapName => "name", action => "createGame", userName => "name", gameName => "name" }, result => "formatError", "createGame: maxPlayers is empty structure", 'is_deeply';

test { maxPlayers => 105, mapName => "map", action => "createGame", userName => "vasya", gameName => "name" }, result => "badMaxPlayers", "createGame: maxPlayers more than 10", 'is_deeply';

test { maxPlayers => 0, mapName => "map", action => "createGame", userName => "vasya", gameName => "name" }, result => "badMaxPlayers", "createGame: maxPlayers is zero", 'is_deeply';

test { maxPlayers => -10, mapName => "map", action => "createGame", userName => "vasya", gameName => "name" }, result => "badMaxPlayers", "createGame: maxPlayers is negative", 'is_deeply';

test { maxPlayers => 1, mapName => "map", action => "createGame", userName => "vasya", gameName => "name" }, result => "badMaxPlayers", "createGame: maxPlayers is 1", 'is_deeply';

test { maxPlayers => "3.5", mapName => "name", action => "createGame", userName => "name", gameName => "name" }, result => "formatError", "createGame: maxPlayers is double", 'is_deeply';

test { maxPlayers => 3, mapName => "new_map", action => "createGame", userName => "vasya", gameName => "name" }, result => "ok", "createGame: all data is valid", 'is_deeply';

test { action => "getGameInfo" }, result => "formatError", "getGameInfo without gameName", 'is_deeply';

test { action => "getGameInfo", gameName => [] }, result => "formatError", "getGameInfo: gameName is empty array", 'is_deeply';

test { action => "getGameInfo", gameName => {} }, result => "formatError", "getGameInfo: gameName is empty structure", 'is_deeply';

test { action => "getGameState" }, result => "formatError", "getGameState without gameName", 'is_deeply';

test { action => "getGameState", gameName => [] }, result => "formatError", "getGameState: gameName is empty array", 'is_deeply';

test { action => "getGameState", gameName => {} }, result => "formatError", "getGameState: gameName is empty structure", 'is_deeply';

test { action => "move" }, result => "formatError", "move without userName and planet", 'is_deeply';

test { planet => 2, action => "move", userName => [] }, result => "formatError", "move: userName is empty array", 'is_deeply';

test { planet => {}, action => "move", userName => "vasya" }, result => "formatError", "move: userName is valid, but planet is empty array", 'is_deeply';

test { planet => "4.75", action => "move", userName => "vasya" }, result => "formatError", "move: userName is valid, but planet is double", 'is_deeply';
