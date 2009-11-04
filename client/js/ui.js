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

function toggleForm(id) {
	$('#'+id).slideToggle('normal');
}

$(document).ready(function() {
		$('.round').wrapInner('<div class="frame_container"></div>');
		$('.round').wrapInner('<div class="frame3_slim"></div>');
		$('.round').wrapInner('<div class="frame3_fat"></div>');
		$('.round').wrapInner('<div class="frame2_slim"></div>');
		$('.round').wrapInner('<div class="frame2_fat"></div>');
		$('.round').wrapInner('<div class="frame1_slim"></div>');
		$('.round').wrapInner('<div class="frame1_fat"></div>');
		$('.dd_form').each(function(ind, item) { $(item).hide() });
	});
