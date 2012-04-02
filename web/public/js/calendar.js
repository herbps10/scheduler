function intersection_safe(a, b)
{
  var ai=0, bi=0;
  var result = new Array();

  while( ai < a.length && bi < b.length )
  {
     if      (a[ai] < b[bi] ){ ai++; }
     else if (a[ai] > b[bi] ){ bi++; }
     else /* they're equal */
     {
       result.push(a[ai]);
       ai++;
       bi++;
     }
  }
  return result;
}

$(document).ready(function() {

	// *********************
	// ** INITIALIZATION **
	// *********************


	//
	// If you're logged in, the schedule data global variable is already set.
	// If you're not logged in, the following code will fire to initialize the variables.
	//
	if(window.schedule_data == null) {
		window.schedule_data = {}
		window.schedule_data.sections = [];
	}

	//
	// Make sure the sidebar components are sized correctly on page load
	//
	resize_components();
	$(window).resize(resize_components); // Attach the resize handler to any window resize event

	// If not logged in, show the intro first
	if(!window.knight_logged_in) {
		$("#resize").fadeOut();
	}

	// If logged in, skip the intro
	if(window.knight_logged_in) {
		$("#intro").hide();
	}
	
	//
	// Initialize Sidebar splitter
	//
	$("#resize").splitter({
		type: "h",
		sizeTop: true,
		resizeToWidth: true
	});

	// ********************
	// ** EVENT HANDLERS **
	// ********************

	// Switcher between courses and calendar view
	$(".switch").click(function() {
		$("p.int1").delay(600).fadeIn('slow');
		$("p.int2").delay(3200).fadeIn('slow');
		$("p.int3").delay(6400).fadeIn('slow');
	});

	// Changes the way the generate button is styled
	// fired when you add a section to your unscheduled courses list
	$(".section button").click(function() {
		$("#regen").addClass("hero");
		$("#regen").removeClass("passive");
		$("#intro").fadeOut();
		$("#resize").delay(600).fadeIn();
	});


	$("#help").live('click', function() {
		$(this).addClass("active")
		$("#resize").fadeOut();
		$("#intro").delay(600).fadeIn();
	});
	

	$("#help.active").live('click', function() {
		$(this).removeClass("active")
		$("#intro").fadeOut();
		$("#resize").delay(1000).fadeIn();
	});


	// Regenerate schedules button
	$("#regen").click(function() {
		$(this).text("Regenerate");
		$(this).removeClass("hero");
		$("#regen").addClass("passive");

		$("#schedules").empty();


		// Build CRN list
		var crns = [];
		for(var i = 0; i < window.schedule_data.sections.length; i++) {
			crns.push(window.schedule_data.sections[i].crn);
		}

		// Fire request for schedules
		get_data(crns, function() {
			draw_schedule(0);
			current_schedule = 0;
			draw_schedule_links();

			if ( 1 < window.schedule_data.schedules.length) {
				$(".more-schedules").delay(1000).fadeIn();
			}

			saveSchedule();
		});
	});


	// View more schedules button that appears below the calendar after schedules are generated
	$(".more-schedules").click(function() {
		$("#schedules").delay(400).fadeIn();
		$(".more-schedules").fadeOut();
	});


	// Hide extra schedules link
	$(".hide-schedules").live('click', function() {
		$("#schedules").fadeOut();
		$(".more-schedules").delay(400).fadeIn();
	});

	
	// Extra schedule link
	// Changes the schedule currently being displayed on the calendar
	$("#schedules a").live('click', function() {

		var index = $(this).attr('rel');

		draw_schedule(index);
		current_schedule = index;
	});


	// Swap button that appears besides sections on the unscheduled sections list
	$("#schedule-conflicts .course button.swap").live({
		mouseenter: function() {
			conflicted_section = get_section_data($(this).parent().attr('rel'));
			var conflicts = get_conflicted_classes(conflicted_section);

			for(var i = 0; i < conflicts.length; i++) {
				var section = conflicts[i];

				$("#calendar .course." + section.crn).addClass('conflict');
				$("#calendar .course." + section.crn).addClass('swapee');
			}

			add_section_to_calendar(conflicted_section);

			$("#calendar .course." + $(this).parent().attr('rel')).addClass('limbo');
		},
		mouseleave: function() {
			conflicted_section = get_section_data($(this).parent().attr('rel'));
			var conflicts = get_conflicted_classes(conflicted_section);

			$("#calendar .course." + conflicted_section.crn).fadeOut('fast', function() {
				$(this).remove();
			});

			$("#calendar .course.conflict").removeClass('conflict');
			$("#calendar .course").removeClass('swapee');
		},
		click: function() {
		$("#calendar .course.limbo").removeClass('limbo');
			conflicted_section = get_section_data($(this).parent().attr('rel'));
			var conflicts = get_conflicted_classes(conflicted_section);

			for(var i = 0; i < conflicts.length; i++) {
				var section = conflicts[i];

				$("#schedule-courses .course." + section.crn + ":first").appendTo("#schedule-conflicts > ul.list").attr('style', '');
				$("#calendar .course." + section.crn).remove();
				$("#schedule-courses .course." + section.crn).remove();
			}

			$(this).parent().appendTo("#schedule-courses > ul.list");
			
			$("#schedule-courses .course." + conflicted_section + " button.close").removeClass('close').addClass('remove');

			saveSchedule();
		}
	});


	// Button that appears besides each section on the scheduled sections list
	// Deletes course from conflicts list
	$("#schedule-conflicts .course .close").live('click', function() {
		var crn = $(this).parent().attr('rel');
		
		var index = 0;
		for(var i = 0; i < window.schedule_data.sections.length; i++) {
			if(window.schedule_data.sections[i].crn == crn) {
				index = i;
				break;
			}
		}

		window.schedule_data.sections.splice(index, 1);

		$(this).parent().remove();

		saveSchedule();
	});


	// Small 'x' button that appears right of sections in currently scheduled section list
	// moves the section back down to the unscheduled courses list
	$("#schedule-courses .course button.remove").live('click', function() {
		var crn = $(this).parent().attr('rel');
		$(this).parent().appendTo("#schedule-conflicts > ul.list");

		$("#calendar .course." + crn).remove();

		$("#schedule-conflicts .course." + crn + " button.remove").removeClass('remove').addClass('close');

		saveSchedule();
	});

	
	// A handful of buttons need to have the state of the page change between calendar and courses view
	$("fieldset.switch input, .add-section, .cancel, button#regen").on('click', function() {
		columnToggle($(this));
	});
});

//
// Get all the available schedules given a list of CRNs
//
function get_data(crns, callback) {
	$.get("/schedules.json", {
			crns: crns
	}, function(data) {
		window.schedule_data = data;

		callback();
	});
}

//
// Retrieve JSON data from the server about a section given its CRN number
//
function get_section_data(crn) {
	for(var i = 0; i < schedule_data.sections.length; i++) {
		if(schedule_data.sections[i].crn == crn) return schedule_data.sections[i];
	}

	return false;
}

//
// If you're logged in, saves the courses in your scheduled
// sections list to the server
//
function saveSchedule() {
	// Check to make sure we're logged in
	if(window.knight_logged_in) {
		var crns = [];

		// Gather the CRNs from the scheduled sections list
		$("#schedule-courses .course").each(function() {
			crns.push($(this).attr('rel'));
		});
		
		$.get("/user/schedule/save", {
			crns: crns
		});
	};
}

function columnToggle(e) {
	if($(e).is("button")) {
		$("#cal").prop("checked", true);
		$("#col").prop("checked", false);
	}
	
	if($("#cal").is(':checked')) {
		$("#course-col").slideUp();
		$("#full-cal-container").slideDown();
	}
	else {
		$("#full-cal-container").slideUp();
		$("#course-col").slideDown();
	}
}


//
// Draws a section to the calendar
//
function add_section_to_calendar(section) {
	for(var t = 0; t < section.times.length; t++) {
		var time = section.times[t];

		for(var d = 0; d < time.days.length; d++) {
			var day = time.days[d];

			if(day == "M") day = "mon"
			if(day == "T") day = "tue"
			if(day == "W") day = "wed"
			if(day == "R") day = "thu"
			if(day == "F") day = "fri"

			$("#calendar").append("<div style='display: none' rel='" + section.crn + "' class='course " + section.crn + " " + day + "'></div>")

			$("#calendar div.course." + section.crn).fadeIn();
		}
	}
	
	$("#calendar ." + section.crn).append(section.title).css("height", time.endPixel-time.startPixel).css("top", time.startPixel + "px");
}

//
// Draws several links to other schedules below the calendar
//
function draw_schedule_links() {
	for(var s = 0; s < window.schedule_data.schedules.length; s++) {
		$("#schedules").append("<a href='#' rel='" + s + "'>Schedule " + s + "</a>");
	}

	$("#schedules").append("<div class='hide-schedules'><<</div>");
}

//
// Draw's a schedule, given in the window.schedule_data object, onto the calendar
// and the scheduled and conflicted sections list in the sidebar.
//
function draw_schedule(schedule_index) {
	var schedule = window.schedule_data.schedules[schedule_index];

	$("#calendar .course").remove();
	$("#schedule-courses .course").remove();
	$("#schedule-conflicts .course").remove();

	for(var i = 0; i < schedule.courses.length; i++) {
		var course = schedule.courses[i];

		add_section_to_calendar(course);
		
		add_to_course_list(course);

	}

	for(var i = 0; i < schedule.conflicts.length; i++) {
		var course = schedule.conflicts[i];
		add_to_conflicts_list(course);
	}
}

function add_to_course_list(course) {
	$("#schedule-courses > .list").append("<li rel='" + course.crn + "' class='course unselectable " + course.crn + "'><button class='remove' /><button class='swap' /><span class='title'>" + course.title + "</span> " + format_times(course.times) + "</div>");
}

function add_to_conflicts_list(course) {
	$("#schedule-conflicts > .list").append("<li rel='" + course.crn + "' class='course unselectable " + course.crn + "'><button class='close' /><button class='swap' /><span class='title'>" + course.title + "</span> " + format_times(course.times) + "</div>");
}

//
// Format a section's time slots for display on the site
//
function format_times(times) {
	var str = "";
	for(var i = 0; i < times.length; i++)
	{
		str += "<span class='days'>";

		for(var d = 0; d < times[i].days.length; d++)
		{
			str += times[i].days[d];
		}

		str += "</span> <span class='times'>" + times[i].startTime + "-" + times[i].endTime + "</span>";
	}

	return str;
}

//
// Check to see if two sections conflict with each other
//
function section_conflict(section1, section2) {
	for(var t1 = 0; t1 < section1.times.length; t1++) {
		var time1 = section1.times[t1];

		for(var t2 = 0; t2 < section2.times.length; t2++) {
			var time2 = section2.times[t2];

			if(times_conflict(time1, time2) == true) {
				return true;
			}
		}
	}

	return false;
}

//
// Get a list of all the courses currently being considered that conflict with the given section
//
function get_conflicted_classes(conflicted_section) {
	conflicts = [];
	for(var i = 0; i < schedule_data.sections.length; i++) {
		var section = schedule_data.sections[i];
		
		if(section == conflicted_section) continue;
		if(section_conflict(section, conflicted_section) == true) {
			conflicts.push(section);
		}

		if(section.department == conflicted_section.department && section.courseNumber == conflicted_section.courseNumber) {
			if(is_lecture_lab(section, conflicted_section) == false) {
				conflicts.push(section);
			}
		}
	}

	return conflicts;
}

function is_lecture_lab(section1, section2) {
				if((section1.title.toLowerCase().indexOf('lab') >= 0 && section2.title.toLowerCase().indexOf('lec')) >= 0 || (section1.title.toLowerCase().indexOf('lec') >= 0 && section2.title.toLowerCase().indexOf('lab') >= 0)) {
					console.log('is lecture lab');
					return true
				}

				console.log('is not lecture lab');

				return false;
}

//
// Check to see if two times overlap each other
//
function times_conflict(time1, time2) {
	if(intersection_safe(time1.days, time2.days).length == 0) return false;

	if(parseInt(time1.startPixel) >= parseInt(time2.startPixel) && parseInt(time1.startPixel) <= parseInt(time2.endPixel)) return true;

	if(parseInt(time1.endPixel) >= parseInt(time2.startPixel) && parseInt(time1.endPixel) <= parseInt(time2.endPixel)) return true;
	
	if(parseInt(time1.startPixel) > parseInt(time2.startPixel) && parseInt(time1.endPixel) < parseInt(time2.endPixel)) return true;

	if(parseInt(time1.startPixel) < parseInt(time2.startPixel) && parseInt(time1.endPixel) > parseInt(time2.endPixel)) return true;


	return false;
}

function resize_components() {
	var window_height = $(window).height();

	$("#main-content").height((window_height - 200) + "px");
	
	if(window_height < 900) {
		$("#sidebar").height((window_height - 202) + "px");
		$("#resize").height((window_height - 202) + "px");
	}
	else {
		$("#sidebar").height("691px");
		$("#resize").height("691px");
	}
}


