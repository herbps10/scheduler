$(document).ready(function() {
	$('.course > li').live('click', function(){
		var $sendRight = $(this).siblings('.sections');

		console.log($(this));

		var $sendLeft = $('.last_expanded');
		var $lastClicked = $('.last_clicked');

		$lastClicked.removeClass('.last_clicked selected_course');
		$(this).addClass('last_clicked');
		$(this).toggleClass('selected_course');

		$sendLeft.toggleClass('expanded_sections last_expanded');
		
		$sendRight.toggleClass('expanded_sections');
		
		$sendRight.animate({
			marginLeft: parseInt($sendRight.css('marginLeft'),10) == 0 ? + $(this).outerWidth(): 0 
		});
		$sendLeft.animate({
			marginLeft: parseInt($sendLeft.css('marginLeft'),10) == 0 ? 0: 0 
		});
		
		$sendRight.addClass('last_expanded');
		
	});

	$('.section').live('click', function() {
		$('#scratch_list').append($(this).text());
		$(this).toggleClass('scratch_list');
	});
});
