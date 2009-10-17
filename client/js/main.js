function tryEnter() {
	$('ui').style.display = 'none';
	var c = Cookie.read('user');
	if(c != null) {
		$('user').value = c;
		showLobby();
	}
}

function connect() {
	//new Request.JSON({'url': host, onSuccess: showLobby}).send({ r: {'action': 'register', 'userName': user} });
	var data = 'r=' + JSON.encode({'action':'register', 'userName': $('user').value});
	new Request({'url': $('host').value, onSuccess: onConnect}).send(data);
}

function onConnect(r) {
	var response = JSON.decode(r);
	if(response.result != 'ok') {
		alert('This username is obtained by another user');
		return;
	}
	Cookie.write('user', $('user').value);
	showLobby();
}

function showLobby() {
	$('hello_dialog').style.display = 'none';
	$('ui').style.display = 'block';
	var f = function () {
		var data = 'r=' + JSON.encode({'action':'getUsers'});
		new Request({'url': $('host').value, onSuccess: updateUsers}).send(data);
	}.periodical(4000);
}


function updateUsers(r) {
	var data = JSON.decode(r);
	var html = '';
	data.users.each(function(item) { html += '<div class="user">' + item + '</div>'; });
	$('userlist').innerHTML = html;
}

function logout() {
	var data = 'r=' + JSON.encode({'action': 'logout', 'userName': $('user').value});
	new Request({'url': $('host').value}).send(data);
	$('ui').style.display = 'none';
	$('hello_dialog').style.display = 'block';
	Cookie.dispose('user');
}

function clearAll() {
	new Request({'url': $('host').value}).send('r={"action":"clear"}');
}
