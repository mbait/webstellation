var WSClient = new Class.create({
	initialize: function(obj) {
		this.ui_handler = obj;
	},

	sendData: function(data, callback) {
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
	
	connect: function(host, user) {
		this.host = host;
		this.user = user;
		this.sendData({action: 'register', userName: this.user}, function(data) {this.onRegister(data);});
	},

	disconnect: function() {
		this.sendData({action: 'logout', userName: this.user});
		this.ui_handler.onLogout();
	},

	onRegister: function(data) {
					alert(data);
		if(!(data.result == 'ok' || data.result == 'alreadyTaken')) {
			return;
		}
		alert(this);
		this.ui_handler.onRegister();
	}
});
