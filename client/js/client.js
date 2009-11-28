var WSClient = new Class.create({
	initialize: function(obj) {
		this.updateTime = 1000;
		this.ui_handler = obj;
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
						 this.ui_handler.render(data);
						 if(data.games != null) {
							 var obj = this;
							 $A(data.games).each(function(val) {
									 obj.sendRequest({action: 'getGameInfo', gameName: val},
										 function(data) {
										 	obj.ui_handler.render(data);
										 })
									 });
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
				 }
});
