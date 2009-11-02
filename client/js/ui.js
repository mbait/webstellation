function btnDown(id) {
	var obj = document.getElementById(id);
	obj.style.left = "1px";
	obj.style.top  = "1px";
}

function btnUp(id) {
	var obj = document.getElementById(id);
	obj.style.left = 0;
	obj.style.top  = 0;
}

function addFrame(name) {
	var obj = document.getElementById(name);
	var text = obj.innerHTML;
	var div = '<div class="frame1_fat"><div class="frame1_slim"><div class="frame2_fat"><div class="frame2_slim">';
	div += '<div class="frame3_fat"><div class="frame3_slim"><div class="frame_container">';
	div = div + text + '</div></div></div></div></div></div></div>';
	obj.innerHTML = div;
}

var a = document.getElementsByTagName('div');
for(var i = 0; i< a.length; ++i) {
	if(a[i].className == 'round') {
		addFrame(a[i].id);
	}
}
