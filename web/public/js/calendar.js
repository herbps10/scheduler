// From http://stackoverflow.com/questions/1187518/javascript-array-difference
// Might not work in IE8


Array.prototype.diff = function(a) { return this.filter(function(i) {return !(a.indexOf(i) > -1);}); }; function intersection_safe(a, b)
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
	if(window.schedule_data == null) {
		window.schedule_data = {}
		window.schedule_data.sections = [];
	}

	//$("#resize").css('height', $("#sidebar").height() - $("#regen").outerHeight(true));
	var listHeight = ($("#calendar-container").height() - $("#sidebar > .title").height() - $("#regen").height()) / 2;
	//$("#schedule-courses").css('height', (listHeight - 100) + "px");
	//$("#schedule-conflicts").css('height', (listHeight) + "px");

	resize_components();
	$(window).resize(resize_components);

	// If not logged in, show the intro first
	if(!window.knight_logged_in) {
		$("#resize").fadeOut();
	}

	if(window.knight_logged_in) {
		$("#intro").hide();
	}
	
	$("#resize").splitter({
		type: "h",
		sizeTop: true,
		resizeToWidth: true
	});

	$(".switch").click(function() {
		$(this).removeClass("hero");
		$(this).addClass("passive");
		$("p.int1").delay(600).fadeIn('slow');
		$("p.int2").delay(3200).fadeIn('slow');
		$("p.int3").delay(6400).fadeIn('slow');
	});

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


	$("#regen").click(function() {
		$(this).text("Regenerate");
		$(this).removeClass("hero");
		$("#regen").addClass("passive");

		$("#schedules").empty();

		var crns = [];

		for(var i = 0; i < window.schedule_data.sections.length; i++) {
			crns.push(window.schedule_data.sections[i].crn);
		}

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

	$(".more-schedules").click(function() {
		$("#schedules").delay(400).fadeIn();
		$(".more-schedules").fadeOut();
	});

	$(".hide-schedules").live('click', function() {
		$("#schedules").fadeOut();
		$(".more-schedules").delay(400).fadeIn();
	});

	$("#small-login #login input[type=submit]").click(function() {
		$.post("/user/authenticate.json", {
			email: $("input[name=email]").val(),
			password: $("input[name=password]").val()
		}, function(data) {
			data = JSON.parse(data);

			console.log(data);
			if(data.success == true){
				window.location = "/dashboard";
			}
			else
			{
				$("#small-login #message").text("Username or password didn't work -- try again?");

				$("#small-login #message").animate({
					opacity: 0.25
				}, 250, function() {
					$("#small-login #message").animate({
						opacity: 1
					}, 250);
				});
			}
		});

		return false;
	});

	$("#user-actions a.user-login").click(function() {
		$("#user-actions-wrapper").fadeIn();
	});

	$("#user-actions a.user-register").click(function() {
		window.location = "/user/register";
	});

	$("#user-actions-wrapper .close").click(function() {
		$("#user-actions-wrapper").fadeOut();
	});
	
	/*
	$("#schedules a").live({
		mouseenter: function() {
			var index = $(this).attr('rel');
			draw_schedule(index);
		},
		mouseleave:  function() {
			draw_schedule(current_schedule);
		}
	});
	*/

	$("#schedules a").live('click', function() {

		var index = $(this).attr('rel');

		draw_schedule(index);
		current_schedule = index;
	});

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
		}
	});

	$("#schedule-conflicts .course .swap").live('click', function() {
		$("#calendar .course.conflict").removeClass('conflict');
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
	});

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

	$("#schedule-courses .course button.remove").live('click', function() {
		var crn = $(this).parent().attr('rel');
		$(this).parent().appendTo("#schedule-conflicts > ul.list");

		$("#calendar .course." + crn).remove();

		$("#schedule-conflicts .course." + crn + " button.remove").removeClass('remove').addClass('close');

		saveSchedule();
	});

	
	$("fieldset.switch input, .add-section, .cancel, button#regen").on('click', function() {
		columnToggle($(this));
	});


	
	$(".subscribe-button").click(function() {
		$.get($(this).attr('href'));
		$(this).text('unsubscribe');

		$(this).attr('href', $(this).attr('href').replace('add', 'remove'));
		return false;
	});

	$(".unsubscribe-button").click(function() {
		$.get($(this).attr('href'));
		$(this).text('subscribe');

		$(this).attr('href', $(this).attr('href').replace('remove', 'add'));
		return false;
	});
});

function columnToggle(e) {
	if($(e).is("button")) {
		$("#cal").prop("checked", true);
		$("#col").prop("checked", false);
		console.log("courses");
	}
	
	if($("#cal").is(':checked')) {
		$("#course-col").slideUp( 'slow', function(){ 
			console.log("hello3")});
		$("#full-cal-container").slideDown();
		console.log("calendar");
	}
	else {
		$("#full-cal-container").slideUp( 'slow', function(){ 
			console.log("hello2")});
		$("#course-col").slideDown();
	}
}

function get_conflicted_classes(conflicted_section) {
	conflicts = [];
	for(var i = 0; i < schedule_data.sections.length; i++) {
		var section = schedule_data.sections[i];
		
		if(section == conflicted_section) continue;
		if(section_conflict(section, conflicted_section) == true) {
			conflicts.push(section);
		}

		if(section.department == conflicted_section.department && section.courseNumber == conflicted_section.courseNumber) {
			conflicts.push(section);
		}
	}

	return conflicts;
}

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

function get_data(crns, callback) {
	$.get("/schedules.json", {
			crns: crns
	}, function(data) {
		window.schedule_data = data;

		callback();
	});
}

function draw_schedule_links() {
	for(var s = 0; s < window.schedule_data.schedules.length; s++) {
		$("#schedules").append("<a href='#' rel='" + s + "'>Schedule " + s + "</a>");
	}

	$("#schedules").append("<div class='hide-schedules'><<</div>");
}

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

function add_to_course_list(course) {
	$("#schedule-courses > .list").append("<li rel='" + course.crn + "' class='course unselectable " + course.crn + "'><button class='remove' /><button class='swap' /><span class='title'>" + course.title + "</span> " + format_times(course.times) + "</div>");
}

function add_to_conflicts_list(course) {
	$("#schedule-conflicts > .list").append("<li rel='" + course.crn + "' class='course unselectable " + course.crn + "'><button class='close' /><button class='swap' /><span class='title'>" + course.title + "</span> " + format_times(course.times) + "</div>");
}

function get_section_data(crn) {
	for(var i = 0; i < schedule_data.sections.length; i++) {
		if(schedule_data.sections[i].crn == crn) return schedule_data.sections[i];
	}

	return false;
}

function section_conflict(section1, section2) {
	for(var t1 = 0; t1 < section1.times.length; t1++) {
		var time1 = section1.times[t1];

		for(var t2 = 0; t2 < section2.times.length; t2++) {
			var time2 = section2.times[t2];

			if(times_conflict(time1, time2) == true) return true;
		}
	}

	return false;
}

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

function saveSchedule() {
	// Check to make sure we're logged in

	if(window.knight_logged_in) {
		var crns = [];

		$("#schedule-courses .course").each(function() {
			crns.push($(this).attr('rel'));
		});
		
		$.get("/user/schedule/save", {
			crns: crns
		});
	};
}
