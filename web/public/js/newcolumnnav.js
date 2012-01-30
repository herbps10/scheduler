$(document).ready(function() {
	
	$('div#columnNav li.department').live('click', function(e) {
		$(e.target).children().children().show();
		$(e.target).siblings().children().children().hide();
	});
	
	$('div#columnNav li.course').live('click', function(e) {
		$(e.target).children().children().show();
		$(e.target).siblings().children().children().hide();
	});

	$('div#columnNav li.section:not(.selected)').live('click', function(e) {
		var crn = $(this).attr('rel')

		$(this).addClass('selected');

		$.get('/section.json', {
			crn: crn
		}, function(data) {
			var section = JSON.parse(data);
			window.schedule_data.sections.push(section);
			
			add_to_conflicts_list(section);

			window.schedule_data.up_to_date = false;
		});
	});

	$('div#columnNav li.section.selected').live('click', function(e) {
		$(e.target).removeClass('selected');
		$("#schedule-conflicts .course." + $(this).attr('rel')).remove();
	});
});
