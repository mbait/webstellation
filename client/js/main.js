function connect() {
	var j = Object.toJSON({ action: 'getUsers' });
	alert(j);
	var r = new Ajax.Request($("host").value, {
		method: 'get',
		parameters: { r: j },
		/*onCreate: function() { alert('created'); },
		onLoaded: function() { alert('loaded'); },*/
		onCreate: checkServer,
		onException: function(req, e) {
			alert(e.name);
			},
		onSuccess: function(r) {
			//document.write(r.getAllHeaders());
			alert(r.getAllHeaders());
		},
		onLoad: function(t) {
			alert(t.status + t.statusText);
		},
		onFailure: function() { alert('failed'); }
	});
}

function checkServer() {
	alert('server');
}
