var WSClient = new Class.create({
	initialize: function(obj) {
		this.updateTime = 1000;
		this.ui_handler = obj;
		this.left_gameInfoUpdate = 0;
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
	// callbacks
	onRegister: function(data) {
					if(!(data.result == 'ok' || data.result == 'alreadyTaken')) {
						return;
					}
					this.startUpdate();
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
						this.ui_handler.render({games: this.gameInfo});
					}
				},
	// updates
	startUpdate: function() {
					 this.doUpdate = true;
					 this.update('Users');
					 this.update('Maps');
					 this.update('Games');
				 },

	update: function(list) {
					 if(!this.doUpdate) { return }
					 var obj = this;
					 this.sendRequest({action: 'get' + list}, function(data) {obj.onUpdateReceive(data)});
					 setTimeout(function() {obj.update(list)}, this.updateTime);
				 },
	// gameInfo updates
	startGameUpdate: function(cnt) {
						 this.left_gameInfoUpdate = cnt;
						 this.gameInfo = {};
					 },

	canUpdateGames: function() {
						return this.left_gameInfoUpdate == 0;
					},

	receiveGameInfo: function(data) {
						this.gameInfo[data.game.name] = {
							name: data.game.name,
							'status': data.game.status,
							action: 'n/a'	  
						};
						this.left_gameInfoUpdate = this.left_gameInfoUpdate - 1;
					}
});
