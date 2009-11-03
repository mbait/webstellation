var host;
var user;

function tryEnter() {
	$(document).ready(function() {
			$('#page').hide();
		});
	alert('all\'s ok');
	alert($.toJSON({"action":"register", "userName":user}, 1, 1));
}

function connect() {
	host = $('#host').val();
	user = $('#user').val();
	$.ajax({
		type: 'POST',
		url: host,
		data: ({r: $.toJSON({'action':'register','userName': user}, 1, 1)}),
		success: function(data) { alert(data); }
	});
}
