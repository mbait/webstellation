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
				$('games').update('');
				try {
				$H(data.games).each(function(pair) {
						var tag = new Element('tr');
						tag.insert(new Element('td').update(pair.value.name));
						tag.insert(new Element('td').update(pair.value.status));
						tag.insert(new Element('td').update( pair.value.action));
						$('games').insert(tag);
				});
				}
				catch(err) {
					alert(err);
				}
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
