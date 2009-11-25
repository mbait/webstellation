var WSUI = new Class.create({
		lookAndFeel: function() {
		},

		toggle: function(id) {
			$(id).toggle();
		},

		onRegister: function() {
			$('auth').hide();
		}
	});
