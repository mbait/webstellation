var Map = new Class.create({
	initialize: function(tag) {
		if(tag == null) { tag = "map" } 
		this.canvasWidth = 600;
		this.canvasHeight = 400;
		this.planetRadius = 7;
		this.planetMaxRadius = this.planetRadius*3;
		this.planetMaxRadius2 = this.planetMaxRadius*2;
		this.baseRadius = 3;
		this.baseRadius2 = this.baseRadius * 2;
		this.clientWidth = this.canvasWidth - this.planetMaxRadius2;
		this.clientHeight = this.canvasHeight - this.planetMaxRadius2;
		this.canvas = new Raphael(tag, this.canvasWidth, this.canvasHeight);
		this.bases = new Array();
		this.planets = new Array();
		this.playerColor = ['orange', 'blue', 'green', 'cyan'];
	},

	init: function(map, callback) {
		this.map = map;
		this.onPlanetClick = callback;
	},

	addPlanet: function(x, y, s, index) {
		 var p =  this.canvas.circle(x, y, s*this.planetRadius);
		 p.attr('fill', '#A9A9A9');
		 var self = this;
		 p.node.onclick = function() { self.onPlanetClick(index) }
		 p.node.onmouseover = function() { p.attr('stroke-width', '2') };
		 p.node.onmouseout = function() { p.attr('stroke-width', '1') };
		 this.planets.push({'x': x, 'y': y, obj: p});
	},

	addBase: function(x, y) {
		var base = this.canvas.circle(x, y, this.baseRadius);
		base.attr('fill', 'red');
		this.bases.push(base.node);
	},

	draw: function() {
		var canvas = this.canvas;
		var maxx = -32768;
		var maxy = maxx;
		var minx = 32768;
		var miny = minx;
		$A(this.map.planets).each(function(planet) {
			maxx = maxx < planet.x ? planet.x : maxx;
			maxy = maxy < planet.y ? planet.y : maxy;
			minx = minx > planet.x ? planet.x : minx;
			miny = miny > planet.y ? planet.y : miny;
		});
		var planets = this.map.planets;
		var w = maxx - minx;
		var h = maxy - miny;
		var mx = this.clientWidth / w;
		var my = this.clientHeight / h;
		var dx = this.planetMaxRadius;
		var dy = this.planetMaxRadius;
		var self = this;
		var spares = {};
		var planet_ind = 0;
		$A(this.map.planets).each(function(planet) {
			spares[planet_ind] = {};
			$A(planet.neighbors).each(function(nb) {
				if(spares[nb] == null || spares[nb][planet_ind] == null) {
					var t = new Template('M#{x0} #{y0}L#{x1} #{y1}');
					try {
					canvas.path(t.evaluate({
					x0: (planet.x - minx )*mx + dx,
					y0: (planet.y - miny )*my + dy,
					x1: (planets[nb].x - minx )*mx + dx,
					y1: (planets[nb].y - miny )*my + dy
					}));
					spares[planet_ind][nb] = 1; } catch(err) { alert(err) }
				}
			 });
		});
		var index = 0;
		$A(this.map.planets).each(function(planet) {
			 //var c = canvas.circle(planet.x*mx + dx , planet.y*my + dy , planet.size*self.planetRadius);
			 self.addPlanet((planet.x-minx)*mx + dx, (planet.y-miny)*my + dy, planet.size, index++);
		});
	},

	update: function(planets) {
		var tag = $('map');
		$A(this.bases).each(function(node) {
			node.parentNode.removeChild(node);
		});
		this.bases.length = 0;
		var self = this;
		var index = 0;
		$A(planets).each(function(state) {
			var planet = self.planets[index];
			var color = state.owner == null? '#A9A9A9': self.playerColor[state.owner];
			planet.obj.attr('fill', color);
			if(state.bases == 1) {
				self.addBase(planet.x, planet.y);
			}
			else if(state.bases == 2) {
				self.addBase(planet.x - self.baseRadius*2, planet.y);
				self.addBase(planet.x + self.baseRadius*2, planet.y);
			}
			else if(state.bases == 3) {
				self.addBase(planet.x, planet.y - self.baseRadius*2);
				self.addBase(planet.x - self.baseRadius*2, planet.y + self.baseRadius*2);
				self.addBase(planet.x + self.baseRadius*2, planet.y + self.baseRadius*2);
			}
			++index;
		});
	}
});

var WSUI = new Class.create({
		lookAndFeel: function() {
			$$('.round').each(function(val) {
				var tag = val;
				$(['frame_container',
				   	'frame3_fat',
				   	'frame3_slim',
				   	'frame2_fat',
				   	'frame2_slim',
				   	'frame1_fat',
				   	'frame1_slim'
				]).each(function(classname) {
					tag = tag.wrap(new Element('div', {class: classname}));
				});
			});
			this.map = new Map();
		},

		showError: function(text) {
			$('errortext').update(text);
		},

		hideError: function(text) {
			$('errortext').update('');
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

		showError: function(text) {
			var err = $('error');
			err.innerText = text;
			err.show();
		},

		hideError: function() {
			$('error').hide();
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
			else if(data.game != null) {
				var game = data.game;
				try {
				this.map.update(game.planets); } catch(err) { alert(err) }
				var score = $('score');
				score.innerHTML = '';
				var p_idx;
				for(var i=0; i<this.players.size(); ++i ) {
					if( this.players[i].name == this.player ) {
						p_idx = i;
						break;
					}
				}
				for(var i=0; i<this.players.size(); ++i) {
					var row = new Element('tr');
					var style = {color: this.map.playerColor[i]};
					var nick = this.players[i].name;
					if(i == p_idx) {
						style.style = 'text-decoration: underline';
						nick = "You are: " + nick;
					}
					var elem = new Element('font', style );
					row.update(new Element('td', {colspan: '2', class: 'score'}).update(elem.update( nick )));
					score.insert(row);
					row = new Element('tr');
					row.insert(new Element('td').update('Planets:'));
					row.insert(new Element('td').update(game.score[i].planets));
					score.insert(row);
					row = new Element('tr');
					row.insert(new Element('td').update('Bases:'));
					row.insert(new Element('td').update(game.score[i].bases));
					score.insert(row);
					row = new Element('tr');
					row.insert(new Element('td').update('Influence:'));
					row.insert(new Element('td').update(game.score[i].influence));
					score.insert(row);
				}
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

		play: function( player, players, map, callback) {
				  this.player = player;
				  this.players = players;
				  this.map.init(map, callback);
				  this.map.draw();
			  },
		// data retrieve
		loginInfo: function() {
					   return { host: $('host').value, user: $('user').value }; 
				   },

		newGameInfo: function() {
						 return { 
							gameName: $('gamename').value,
							mapName: $('mapname').value,
							maxPlayers: $('maxplayers').value
						 }
					 }
	});
