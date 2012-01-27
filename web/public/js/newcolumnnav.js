$(document).ready(function() {
	
	$('div#columnNav').live('click', function(e){
		switch($(e.target).attr('class')){
			case 'department':
				$(e.target).children().children().show();
				$(e.target).siblings().children().children().hide();

			break;
			case 'course':
				$(e.target).children().children().show();
				$(e.target).siblings().children().children().hide();

			break;
			case 'section':
				$(e.target).addClass('selected');
				$("#schedule-conflicts").append("<div class='course " + $(e.target).attr('rel') + "'>" + $(e.target).text() + "</div>");
			break;
			case 'section selected':
				$(e.target).removeClass('selected');
				$("#schedule-conflicts .course." + $(e.target).attr('rel')).remove();
			break;
		}
	});

});
