var WSClient = new Class.create({
	initialize: function(obj) {
		this.updateTime = 1000;
		this.ui_handler = obj;
	},

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

	onRegister: function(data) {
		if(!(data.result == 'ok' || data.result == 'alreadyTaken')) {
			return;
		}
		this.startUpdate();
		this.ui_handler.onRegister();
	},

	startUpdate: function() {
					 this.doUpdate = true;
					 this.update('Users');
					 this.update('Maps');
					 this.update('Games');
				 },

	update: function(list) {
					 if(!this.doUpdate) { return }
					 var obj = this;
					 this.sendRequest({action: 'get' + list}, function(data) {obj.ui_handler.render(data)});
					 setTimeout(function() {obj.update(list)}, this.updateTime);
				 }
});
