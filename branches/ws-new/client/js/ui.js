var WSUI = new Class.create({
		lookAndFeel: function() {
		},

		toggle: function(id) {
			$(id).toggle();
		},

		onRegister: function() {
			$('auth').hide();
		},

		onLogout: function() {
			$('auth').show();
		},

		render: function(data) {
			if(data.users != null) {
				var obj = $('userlist');
				obj.update('');
				$A(data.users).each(function(val) {obj.insert(new Element('a', {class: 'user', href: '#'}).update(val))});
			}
			else if(data.maps != null) {
				var obj = $('mapname');
				var old = obj.value;
				obj.update('');
				$A(data.maps).each(function(val) {obj.insert(new Element('option', {value: val}).update(val))});
				obj.value = old;
			}
			else if(data.games != null) {
				var obj = $('games');
				obj.update('');
				$A(data.games).each(function(val) {
						var tag = new Element('tr');
						tag.update(new Element('td').update(val));
						tag.insert(new Element('td').update('n/a'));
						tag.insert(new Element('td').update('n/a'));
						obj.insert(tag);
					});
				this.games = $A(data.games);
			}
			else if(data.game != null) {
				var obj = $('games');
				obj.update('');
				var game = data.game;
				this.games.each(function(val) {
						var tag = new Element('tr');
						//var state = game.name == val ? game.status : 'n/a';
						var state = game.status;
						var action = 'n/a';
						tag.update(new Element('td').update(val));
						tag.insert(new Element('td').update(state));
						tag.insert(new Element('td').update(action));
						obj.insert(tag);
					});
			}
		},

		loginInfo: function() {
					   return { host: $('host').value, user: $('user').value }; 
				   },

		newGameInfo: function() {
						 return { 
							gameName: $('gamename').value,
							mapName: $('mapname').value,
							maxPlayers: $('maxplayers').value,
						 }
					 }
	});
