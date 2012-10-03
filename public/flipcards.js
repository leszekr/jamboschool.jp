$(document).ready(function(){
	$('.flip-button').click(function(){
		$(this).parents('.flipcard').toggleClass('flip');
		return false;
	});
	$(".flipcard").each(function(){
		$(this).css("height",$(this).find(".front").height());
	})
})