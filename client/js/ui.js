var WSUI = new Class.create({
		lookAndFeel: function() {
			this.canvasWidth = 800;
			this.canvasHeight = 600;
			this.planetRadius = 7;
			this.planetMaxRadius = this.planetRadius*3;
			this.planetMaxRadius2 = this.planetMaxRadius*2;
			this.clientWidth = this.canvasWidth - this.planetMaxRadius2;
			this.clientHeight = this.canvasHeight - this.planetMaxRadius2;
			this.gameCanvas = new Raphael("map", this.canvasWidth, this.canvasHeight);
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
				var obj = this;
				this.player = data.player;
				this.game = data.playerGame;
				$H(data.games).each(function(pair) {
						var players = new Template('#{in}(#{whole})');
						var tag = new Element('tr').observe('click', function() {obj.showGameUsers(pair.value)});
						tag.insert(new Element('td').update(pair.value.name));
						tag.insert(new Element('td').update(players.evaluate({in: $A(pair.value.players).size(), whole: pair.value.maxPlayers})));
						tag.insert(new Element('td').update(pair.value.status));
						var action = '\t';
						var attrs = {href: '#'};
						if(data.playerGame == null) {
							action = 'join';
							var tmpl = new Template("client.joinGame('#{name}')");
							attrs.onclick = tmpl.evaluate({name: pair.value.name});
						}
						else if(data.playerGame == pair.value.name) {
							action = 'leave';
							attrs.onclick = 'client.leaveGame()';
						}
						if(action != null) {
							tag.insert(new Element('td').update(new Element('a', attrs).update(action)));
						}
						$('games').insert(tag);
						if(pair.value.name == obj.activeGame) {
							obj.showGameUsers(pair.value)
						}
				});
			}
		},

		showGameUsers: function(game) {
						   var tag = $('gameusers');
						   var row;
						   var attrs = {type: 'checkbox', onclick: 'client.toggleReady()'};
						   tag.update('');
						   var me = this;
						   $A(game.players).each(function(val) {
								row = new Element('tr');
								row.insert(new Element('td').update(val.name));
								attrs.checked = (val.isReady)? 'checked' : null;
								attrs.disabled = (me.player != val.name)?  'disabled' : null;
								row.insert(new Element('td').update(new Element('input', attrs)));
								tag.insert(row);
							});
						   this.activeGame = game.name;
					   },

		play: function(data) {
				  this.map = data.map;
				  this.drawMap();
			  },

		drawMap: function() {
					 var canvas = this.gameCanvas;
					 var maxx = -32768;
					 var maxy = maxx;
					 var minx = 32768;
					 var miny = minx;
					 var m = function(planet) {
						 maxx = maxx < planet.x ? planet.x : maxx;
						 maxy = maxy < planet.y ? planet.y : maxy;
						 minx = minx > planet.x ? planet.x : minx;
						 miny = miny > planet.y ? planet.y : miny;
					 }
					 var planets = this.map.planets;
					 $A(planets).each(m);
					 var w = maxx - minx;
					 var h = maxy - miny;
					 var mx = this.clientWidth / w;
					 var my = this.clientHeight / h;
					 var dx = this.planetMaxRadius;
					 var dy = this.planetMaxRadius;
					 var me = this;
					 var spares = {};
					 var planet_ind = 0;
					 var f = function(planet) {
						 spares[planet_ind] = {};
						 var e = function(nb) {
							 if(spares[nb] == null || spares[nb][planet_ind] == null) {
								 //canvas.line(planet.x*mx + dx, planet.y*my + dy, planets[nb].x*mx + dx, planet[nb].y*my + dy);
								 var t = new Template('M#{x0} #{y0}L#{x1} #{y1}');
								 try {
								 canvas.path(t.evaluate({
									x0: planet.x*mx + dx,
								   	y0: planet.y*my + dy,
								   	x1: planets[nb].x*mx + dx,
								   	y1: planets[nb].y*my + dy
								 }));
								 spares[planet_ind][nb] = 1; } catch(err) { alert(err) }
							 }
						 };
						 $A(planet.neighbors).each(e);
						 var c = canvas.circle(planet.x*mx + dx , planet.y*my + dy , planet.size*me.planetRadius);
						 c.attr('fill', '#A9A9A9');
						 planet_ind = planet_ind + 1;
					 };
					 $A(planets).each(f);
				 },
		// data retrieve
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
