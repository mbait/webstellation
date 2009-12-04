var WSClient = new Class.create({
	initialize: function(obj) {
		this.updateTime = 1000;
		this.left_gameInfoUpdate = 0;
		this.ui_handler = obj;
		var me = this;
	},
	// helper methods
	sendRequest: function(data, callback) {
		new Ajax.Request(this.host, {
			method: 'post',
			parameters: {r: $H(data).toJSON()},
			onSuccess: function(t) {
				if(callback != null) {
					callback(t.responseText.evalJSON());
				}
			}
		});
	},
	// main actions
	connect: function(data) {
		this.host = data.host;
		this.user = data.user;
		var obj = this;
		this.sendRequest({action: 'register', userName: this.user}, function(data) {obj.onRegister(data)});
	},

	disconnect: function() {
		this.sendRequest({action: 'logout', userName: this.user});
		this.ui_handler.onLogout();
	},

	createGame: function(data) {
					data.action = 'createGame';
					data.userName = this.user;
					this.sendRequest(data);
				},

	toggleReady: function() {
					 this.sendRequest({action: 'toggleReady', userName: this.user});
				 },

	joinGame: function(gameid) {
				  this.sendRequest({action: 'joinGame', userName: this.user, gameName: gameid});
			  },

	leaveGame: function(gameid) {
				   this.sendRequest({action: 'leaveGame', userName: this.user});
			   },

	move: function(ind) {
			  this.sendRequest({action: 'move', userName: this.user, planet: ind});
		  },
	// callbacks
	onRegister: function(data) {
					if(!(data.result == 'ok' || data.result == 'alreadyTaken')) {
						return;
					}
					this.startUpdate(['Users', 'Maps', 'Games']);
					this.ui_handler.onRegister();
				},

	onUpdateReceive: function(data) {
						 if(data.games != null ) {
							 if(this.canUpdateGames()) {
								 this.startGameUpdate($A(data.games).size());
								 var obj = this;
								 $A(data.games).each(function(val) {
										 obj.sendRequest({action: 'getGameInfo', gameName: val},
											 function(data) {
												obj.onGameInfo(data)
											 })
										 });
							 }
						 }
						 else {
							 this.ui_handler.render(data);
						 }
					 },

	onGameInfo: function(data) {
					this.receiveGameInfo(data);
					if(this.canUpdateGames()) {
						this.ui_handler.render({player: this.user, playerGame: this.activeGame,  games: this.gameInfo});
					}
				},
	// updates
	startUpdate: function(list) {
					 this.doUpdate = true;
					 this.updateList = $A(list);
					 var me = this;
					 $A(list).each(function(val) { me.update(val) });
				 },

	stopUpdate: function() {
					clearTimeout();
					this.doUpdate = false;
				},

	update: function(list) {
					 if(!this.doUpdate) { return }
					 if(!this.updateList.member(list)) { return }
					 var obj = this;
					 var params = {action: 'get' + list};
					 if(list == 'GameState') { params.gameName = this.playingGame }
					 this.sendRequest(params, function(data) {obj.onUpdateReceive(data)});
					 if(this.doUpdate) { setTimeout(function() {obj.update(list)}, this.updateTime) }
				 },
	// gameInfo updates
	startGameUpdate: function(cnt) {
						 this.activeGame = null;
						 this.left_gameInfoUpdate = cnt;
						 this.gameInfo = {};
					 },

	stopGameUpdate: function() {
					   this.left_gameInfoUpdate = 0;
				   },

	canUpdateGames: function() {
						return this.left_gameInfoUpdate == 0;
					},

	receiveGameInfo: function(data) {
						if(!this.doUpdate) { return }

						var game = data.game;
						var me = this;
						$A(game.players).each(function(val){if(me.user == val.name){me.activeGame = game.name}});
						if(game.status == 'playing' && game.name == this.activeGame) {
							this.stopGameUpdate();
							this.stopUpdate();
							this.sendRequest({action: 'getMapInfo', mapName: game.map}, 
									function(data) { me.ui_handler.play(game.players, data.map, function(ind) { me.move(ind) }) });
							this.playingGame = game.name;
							this.startUpdate(['GameState']);
						}
						else {
							this.gameInfo[data.game.name] = game;
							this.left_gameInfoUpdate = this.left_gameInfoUpdate - 1;
						}
					}
});
