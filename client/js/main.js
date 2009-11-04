var host;
var user;
var gamestate;
var doUpdate = false;
var mygameId;
var curgameId;

function ajaxError(obj, text, code) {
	alert(text);
	return false;
}

function serverError(r) {
	if(r.result != 'ok') {
		alert('Error code: ' + r.result + '\nText: ' + r.message);
		return false;
	}
	return true;
}


function sendRequest(json, callback) {
	if(callback == null) { callback = function(r) { serverError($.evalJSON(r)) } }
	$.ajax({type: 'POST', url: host, data: ({r: $.toJSON(json)}), success: callback, error: ajaxError});
}


function tryEnter() {
	$(document).ready(function() {
			$('#page').hide();
		});
}

function resetView() {
	gamestate = {game: {}};
	doUpdate = true;
}

function connect() {
	host = $('#host').val();
	user = $('#user').val();
	if(host == null) {
		alert('Host must be specified!');
		return false;
	}
	if(user == null) {
		alert('User must be specified!');
		return false;
	}
	sendRequest({action:'register', userName: user}, function(data) { 
			var r = $.evalJSON(data);
			if(!(r.result == 'ok' || r.result == 'alreadyTaken')) {
				return serverError(r);
			}
			$('#auth').fadeOut('normal', function() { $('#page').fadeIn() });
			
			resetView();
			refresh();
			render();
		});
}

function createGame() {
	if(!$('#game_name').val()) { alert('Game name must be specified!'); return false;  }
	if(!$('#map_name').val()) { alert('Map name must be specified!'); return false; }
	sendRequest({action: 'createGame', 
			userName: user,
			gameName: $('#game_name').val(),
			mapName: $('#map_name').val(),
			maxPlayers: $('#max_players').val()
			}, function(r) {
				var json = $.evalJSON(r);
				if(json.result == 'ok') { toggleForm('create_game') }
				else { serverError(json) }
			});
	
}

function viewGame(id) {
	curgameId = id;
	render();
}

function toggleReady(id) {
	doUpdate = false;
	sendRequest({action: 'toggleReady', userName: id}, function(r) { doUpdate = true });
}

function render() {
	if(!doUpdate) { return false }

	$('#users').html('');
	var map_value = $('#map_name').val();
	$('#map_name').html('');
	if(gamestate.users) {
		$.each(gamestate.users, function(ind, item) {
				$('#users').append('<a href="#">'+item+'</a>\n');
			});
	}
	if(gamestate.maps) {
		$.each(gamestate.maps, function(ind, item) {
				$('#map_name').append('<option value="'+item+'">'+item+'</option>');
			});
		$('#map_name').val(map_value);
	}
	$('#games tbody').html('');
	if(gamestate.games) {
		$.each(gamestate.games, function(ind, item) {
			var state = 'n/a';
			var action = 'n/a';
			if(gamestate.game[item] != null) { 
				state = gamestate.game[item].status;
			} 
			$('#games tbody').append('<tr onclick="viewGame(\''+item+'\')"><td>'+item+'</td>' + 
				state + '</td><td><a href="#">'+action+'</a></td></tr>');
		});
	}
	$('#game_users').html('');
	if(curgameId && gamestate.game[curgameId] != null) {
		$(gamestate.game[curgameId].players).each(function(ind, val) {
				var checked = val.isReady?'checked':'';
				$('#game_users').append('<div><input type="checkbox" ' + 
					checked + ' onclick="toggleReady(\''+val.name+'\')">'+val.name+'</div>')
			});
	}
	setTimeout('render()', 2000);
}

function refresh() {
	if(!doUpdate) { return false }
	// get users
	sendRequest({action:'getUsers'}, function(data) {
			var r = $.evalJSON(data);
			if(r.result != 'ok') { return serverError(r) }
			gamestate.users = r.users;
		});
	// get maps
	sendRequest({action:'getMaps'}, function(data) {
			var r = $.evalJSON(data);
			if(r.result != 'ok') { return serverError(r) }
			gamestate.maps = r.maps;
		});
	// get games
	sendRequest({action:'getGames'}, function(data) {
			var r = $.evalJSON(data);
			if(r.result != 'ok') { return serverError(r) }
			gamestate.games = r.games;
			$(r.games).each(function(ind, val) {
				sendRequest({action:'getGameInfo', gameName: val}, function(r) {
					var data = $.evalJSON(r);
					gamestate.game[data.game.name] = data.game;
				})
			});
		});
	setTimeout('refresh()', 4000);
}

function logout() {
	doUpdate = false;
	sendRequest({action: 'logout', userName: user});
	$('#page').fadeOut('normal', function() { $('#auth').fadeIn('normal') });
}
