

# Overview #

Clients use series of requests in [JSON](http://www.json.org/) format to communicate with a game server.  Requests are sent between a client and a server using POST method of HTTP protocol, where the text of a query is stored as value of the only variable named **r**.  Each query is an object (an unordered set of name/value pairs) that contains parameters of a game operation.  The correct query has mandatory parameter `action` containing the identifier of an operation for the server to perform.  Presence or absence of other parameters depends on a particular action.

The server's response on a request is also a JSON object with mandatory field `result` (containing string "`ok`", meaning successful query execution, or the identifier of an error occurred from the list [below](#Error_Messages.md)).  Optionally, any response has field `message` containing a text message to the end user.  Again, depending on the type of an action, response object contains additional fields describing the result of an operation.

# HTTP format #

Server must use [application/json](http://www.ietf.org/rfc/rfc4627.txt) MIME type in response headers. All error results (i.e. are not containing `ok` in `result` field) must be followed with [HTTP status code](http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html) `400` - [Bad request](http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html#sec10.4.1). Otherwise it must be `200` [OK](http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html#sec10.2.1).

# Error Messages #

## Map Related Errors ##

| `mapExists` | The specified title is already used to name another map. |
|:------------|:---------------------------------------------------------|
| `unknownMap` | A map with the specified name is not registered yet. |
| `badMapInfo` | The object of [MapInfo](#MapInfo.md) structure is not formatted correctly. |

## User Related Errors ##

| `alreadyTaken` | The specified user name is already taken by another user. |
|:---------------|:----------------------------------------------------------|
| `unknownUser` | A user with the specified name is not registered yet. |
| `alreadyInGame` | The specified user is already playing a game. |
| `notInGame` | The specified user is not playing any game currently. |

## Game Related Errors ##

| `gameExists` | The specified title is already used to name another game. |
|:-------------|:----------------------------------------------------------|
| `unknownGame` | A game with the specified name was not registered yet. |
| `badGameInfo` | The object of [GameInfo](#GameInfo.md) structure is not formatted correctly. |
| `badGameState` | The object of [GameState](#GameState.md) structure is not formatted correctly. |
| `badMaxPlayers` | The specified maximal number of players allowable to compete in a  game is incorrect. |
| `alreadyMaxPlayers` | The number of registered players in a game is already maximal, so it is impossible to join the game currently. |
| `alreadyStarted` | The specified game is already started. |
| `notStarted` | The specified game is not started yet. |
| `notYourTurn` | The specified player could not make a move because it is turn of another player. |
| `badPlanet` | The index of a planet to build a base on is incorrect. |

## Other Errors ##

| `formatError` | Format of the specified request is incorrect, meaning malformed JSON string, invalid types or values of parameters in the query. |
|:--------------|:---------------------------------------------------------------------------------------------------------------------------------|
| `generalError` | Any error other than that listed above. |


# Structures #

## Map Related Structures ##

### `MapInfo` ###

A map is represented by undirected, unweighted graph which is a model of the star system.  Note that for purposes of visual simplicity a _planar_ graph is desirable.

| `name` | _string_ | Name of the game map. |
|:-------|:---------|:----------------------|
| `planets` | _array_ | [PlanetInfo](#PlanetInfo.md) structures that represent the planets and its' positions on the map; order is not important. |

### `PlanetInfo` ###

| `x` | _integer_ | X-coordinate of the planet on Cartesian plane. |
|:----|:----------|:-----------------------------------------------|
| `y` | _integer_ | Y-coordinate of the planet on Cartesian plane. |
| `size` | _integer_ | Size of the planet; equals to 1, 2, or 3. |
| `neighbors` | _array_ | Indices of the adjacent planets (starting from zero) in `planets` array of [MapInfo](#MapInfo.md) structure; order is not important. |

### `PlanetState` ###

| `owner` | _integer_ | Index of the player who owns the planet (starting from zero) in `players` array of `GameInfo` structure, or _nil_ if the planet is neutral. |
|:--------|:----------|:--------------------------------------------------------------------------------------------------------------------------------------------|
| `bases` | _integer_ | The number of bases built on the planet; lays in range from zero to the size of this planet. |

## Player Related Structures ##

### `PlayerInfo` ###

| `name` | _string_ | Name of the player. |
|:-------|:---------|:--------------------|
| `isReady` | _boolean_ | Readiness of the player to start the game if he has joined one, or _nil_ if he has not or if game is already playing, so readiness is not relevant. |

### `PlayerScore` ###

| `planets` | _integer_ | The number of planets owned by the player, or _nil_ if the player has surrendered. |
|:----------|:----------|:-----------------------------------------------------------------------------------|
| `bases` | _integer_ | The number of bases owned by the player, or _nil_ if the player has surrendered. |
| `influence` | _integer_ | The total influence of the player, or _nil_ if the player has surrendered. |

## Game Related Structures ##

### `GameInfo` ###

| `name` | _string_ | Name of the game. |
|:-------|:---------|:------------------|
| `map` | _string_ | Name of the game map used. |
| `maxPlayers` | _integer_ | The maximal allowable number of players in the game. |
| `players` | _array_ | [PlayerInfo](#PlayerInfo.md) structures that represent the players; sorted in the order of joining the game (so the player who's created it is always the first one). |
| `status` | _string_ | Status of the game; equals to "`preparing`", "`playing`", "`finished`", or "`loaded`".|

### `GameState` ###

| `active` | _integer_ | Index of the player who makes the turn (starting from zero) in `players` array of `GameInfo` structure, or _nil_ if the game has finished. |
|:---------|:----------|:-------------------------------------------------------------------------------------------------------------------------------------------|
| `planets` | _array_ | [PlanetState](#PlanetState.md) structures that represent state of the planets; sorted in exactly the same order as `planets` array in `MapInfo` structure. |
| `score` | _array_ | [PlayerScore](#PlayerScore.md) structures that represents score of every player in the game; sorted in exactly the same order as `players` array in `GameInfo` structure. |


# Queries #

Query is entirely defined by set of its input and output parameters, as well as a list of types of errors that may occur during processing.

All the queries has parameters:
| **`>`** | `action` | _string_ | Name of the action to execute from the list below; all other parameters are depend on it. |
|:--------|:---------|:---------|:------------------------------------------------------------------------------------------|

| **`<`** | `result` | _string_ | "`ok`" or [error identifier](#Error_Messages.md). |
|:--------|:---------|:---------|:--------------------------------------------------|
| **`<`** | `message` | _string_ | Descriptive text. |

Regardless of the type of a query errors of these types could occur:
| **`!`** | `formatError` |
|:--------|:--------------|
| **`!`** | `generalError` |

If errors of several types occurred at the same time, then the only one of them is reported, that that listed earlier in the list of errors of the processing query.  `formatError` is always first type in list of error types of a query, and `generalError` is always last one.  Other possible types of errors are listed below for each action.

## Map Related Queries ##

### `getMaps` ###

List registered maps.

| **`<`** | `maps` | _array_ | Names of already registered maps ordered lexicographically. |
|:--------|:-------|:--------|:------------------------------------------------------------|

### `getMapInfo` ###

Return information about a map.

| **`>`** | `mapName` | _string_ | Name of the map. |
|:--------|:----------|:---------|:-----------------|

| **`<`** | `map` | _[MapInfo](#MapInfo.md)_ | Description of the map. |
|:--------|:------|:-------------------------|:------------------------|

| **`!`** | `unknownMap` |
|:--------|:-------------|

### `uploadMap` ###

Upload a map to the game server.

| **`>`** | `mapInfo` | _[MapInfo](#MapInfo.md)_ | Description of the map to upload. |
|:--------|:----------|:-------------------------|:----------------------------------|

| **`!`** | `mapExists` |
|:--------|:------------|
| **`!`** | `badMapInfo` |

## User Related Queries ##

### `getUsers` ###

List registered users.

| **`<`** | `users` | _array_ | Names of already registered users ordered lexicogrphically. |
|:--------|:--------|:--------|:------------------------------------------------------------|

### `register` ###

Register a user on the game server.

| **`>`** | `userName` | _string_ | Name of the user. |
|:--------|:-----------|:---------|:------------------|

| **`!`** | `alreadyTaken` |
|:--------|:---------------|

### `joinGame` ###

Join the specified user to a game.

| **`>`** | `userName` | _string_ | Name of the user. |
|:--------|:-----------|:---------|:------------------|
| **`>`** | `gameName` | _string_ | Name of the game. |

| **`!`** | `unknownGame` |
|:--------|:--------------|
| **`!`** | `unknownUser` |
| **`!`** | `alreadyInGame` |
| **`!`** | `alreadyStarted` |
| **`!`** | `alreadyMaxPlayers` |

### `toggleReady` ###

Toggle player's readiness to start the game he's joined.  A game is started only when all of the participating players have declared their readiness.

| **`>`** | `userName` | _string_ | Name of the user. |
|:--------|:-----------|:---------|:------------------|

| **`!`** | `unknownUser` |
|:--------|:--------------|
| **`!`** | `notInGame` |

### `leaveGame` ###

Unregister a player from the game he's participating, but let him to watch.

| **`>`** | `userName` | _string_ | Name of the user. |
|:--------|:-----------|:---------|:------------------|

| **`!`** | `unknownUser` |
|:--------|:--------------|
| **`!`** | `notInGame` |

### `logout` ###

Unregister a user from the game server.

| **`>`** | `userName` | _string_ | Name of the user. |
|:--------|:-----------|:---------|:------------------|

| **`!`** | `unknownUser` |
|:--------|:--------------|

## Game Related Queries ##

### `getGames` ###

List registered games.

| **`<`** | `games` | _array_ | Names of already registered games ordered lexicographically. |
|:--------|:--------|:--------|:-------------------------------------------------------------|

### `getGameInfo` ###

Return information about a game.

| **`>`** | `gameName` | _string_ | Name of the game. |
|:--------|:-----------|:---------|:------------------|

| **`<`** | `game` | _[GameInfo](#GameInfo.md)_ | Description of the game. |
|:--------|:-------|:---------------------------|:-------------------------|

| **`!`** | `unknownGame` |
|:--------|:--------------|

### `createGame` ###

Create a game on the game server.

| **`>`** | `gameName` | _string_ | Name of the game. |
|:--------|:-----------|:---------|:------------------|
| **`>`** | `userName` | _string_ | Name of the user that creates the game.  Note that this user would have the first turn (see description of [GameInfo](#GameInfo.md) structure). |
| **`>`** | `mapName` | _string_ | Name of the game map to use. |
| **`>`** | `maxPlayers` | _integer_ | The maximal allowable number of players in this game; should be in range from 2 to 10. |

| **`!`** | `unknownUser` |
|:--------|:--------------|
| **`!`** | `unknownMap` |
| **`!`** | `gameExists` |
| **`!`** | `badMaxPlayers` |
| **`!`** | `alreadyInGame` |

### `loadGame` ###

Upload a saved earlier game.

| **`>`** | `userName` | _string_ | Name of the user that uploads this game. |
|:--------|:-----------|:---------|:-----------------------------------------|
| **`>`** | `gameInfo` | _[GameInfo](#GameInfo.md)_ | Description of the game. |
| **`>`** | `gameState` | _[GameState](#GameState.md)_ | State of the game at the moment of saving. |

| **`!`** | `unknownUser` |
|:--------|:--------------|
| **`!`** | `gameExists` |
| **`!`** | `badGameInfo` |
| **`!`** | `badGameState` |
| **`!`** | `alreadyInGame` |

### `getGameState` ###

Return the state of a game playing.

| **`>`** | `gameName` | _string_ | Name of the game. |
|:--------|:-----------|:---------|:------------------|

| **`<`** | `game` | _[GameState](#GameState.md)_ | Description of the current state of the game. |
|:--------|:-------|:-----------------------------|:----------------------------------------------|

| **`!`** | `unknownGame` |
|:--------|:--------------|
| **`!`** | `notStarted` |

### `move` ###

Make a move.

| **`>`** | `userName` | _string_ | Name of the user that makes the move. |
|:--------|:-----------|:---------|:--------------------------------------|
| **`>`** | `planet` | _integer_ | Index of the planet where new base should be built.  Planets are numbered starting from zero and ordered as in `planets` array of [MapInfo](#MapInfo.md) structure. |

| **`!`** | `unknownUser` |
|:--------|:--------------|
| **`!`** | `notInGame` |
| **`!`** | `notStarted` |
| **`!`** | `notYourTurn` |
| **`!`** | `badPlanet` |

### `surrender` ###

Concede a player's defeat.

| **`>`** | `userName` | _string_ | Name of the surrendered player. |
|:--------|:-----------|:---------|:--------------------------------|

| **`!`** | `unknownUser` |
|:--------|:--------------|
| **`!`** | `notInGame` |
| **`!`** | `notStarted` |
| **`!`** | `notYourTurn` |

## Other Queries ##

### `clearAll` ###

Delete any information stored by game server; _for testing purposes only_.