function connect() {
	//new Request.JSON({'url': host, onSuccess: showLobby}).send({ r: {'action': 'register', 'userName': user} });
	var data = 'r=' + JSON.encode({'action':'register', 'userName': $('user').value});
	new Request({'url': $('host').value, onSuccess: showLobby}).send(data);
}

function showLobby(r) {
	var response = JSON.decode(r);
	if(response.result != 'ok') {
		alert('This username is obtained by another user');
		return;
	}
	$('hello_dialog').style.display = 'none';
	$('ui').style.display = 'block';
	var f = function () {
		var data = 'r=' + JSON.encode({'action':'getUsers'});
		new Request({'url': $('host').value, onSuccess: updateUsers}).send(data);
	}.periodical(2000);
}


function updateUsers(r) {
	var data = JSON.decode(r);
	var html = '';
	data.users.each(function(item) { html += '<div class="user">' + item + '</div>'; });
	$('userlist').innerHTML = html;
}

function clearAll() {
	new Request({'url': $('host').value}).send('r={"action":"clear"}');
}
