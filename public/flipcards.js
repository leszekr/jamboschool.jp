$(document).ready(function(){
	$('.flip-button').click(function(){
		$(this).parents('.flipcard').toggleClass('flip');
		return false;
	})
})