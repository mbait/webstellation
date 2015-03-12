The game involves two or more players competing for control over a star system.

A star system is represented by planar graph with given number of vertices.  Each vertex represents a planet of size one, two, or three.

Each turn a player can build a base on any of the planets where there are no bases of other players.  Maximal possible number of bases on a planet equals to the size of this planet.

The total number of bases that a player has on any particular planet and all its neighbors is considered as the player's impact on this planet.

A planet is owned by that player whose influence on it is the highest.  If more than one players have maximal impacts on the planet and there is at least one base on it, the planet belongs to the owner of this base (even if his impact is not the highest).  Otherwise the planet is considered to be a neutral one.

If as a result of a turn some planet passed from one player to another, all bases on it are destroyed. All rules above produce following algorithm:
  1. Player places a base on some planet.
  1. Influence is calculated for each planet. If some planet changes owner its bases will be deleted.
  1. Repeat step 2 until there are no bases to delete.

A player on his turn can concede his defeat and leave the game.  In that case all the bases built by this player are destroyed and ownership of the planets that were in his possession is recalculated using the rules mentioned above.

The game lasts until either all planets are owned or number of players becomes less than two.

The winner of the game is determined by following procedure.
  1. Select the players who own maximal number of planets.
  1. Keep among the selected those who has more bases than others.
  1. Choose those of them with the highest total impact.