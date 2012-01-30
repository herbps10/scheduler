// From http://stackoverflow.com/questions/1187518/javascript-array-difference
// Might not work in IE8


Array.prototype.diff = function(a) {
    return this.filter(function(i) {return !(a.indexOf(i) > -1);});
};

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
	get_data(['55374', '50608', '54582', '50371', '50315', '50622', '55517', '53456'], function() {
		draw_schedule(0);
		draw_schedule_links();
		current_schedule = 0;
	});

	$("#regen").click(function() {
		var crns = [];

		for(var i = 0; i < window.schedule_data.sections.length; i++) {
			crns.push(window.schedule_data.sections[i].crn);
		}

		get_data(crns, function() {
			draw_schedule_links();
		});
	});
	
	$("#schedules a").live({
		mouseenter: function() {
			var index = $(this).attr('rel');
			draw_schedule(index);
		},
		mouseleave:  function() {
			draw_schedule(current_schedule);
		}
	});

	$("#schedules a").live('click', function() {
		var index = $(this).attr('rel');

		draw_schedule(index);
		current_schedule = index;
	});

	$("#schedule-conflicts .course").live({
		mouseenter: function() {
			conflicted_section = get_section_data($(this).attr('rel'));
			var conflicts = get_conflicted_classes(conflicted_section);

			for(var i = 0; i < conflicts.length; i++) {
				var section = conflicts[i];

				$("#calendar .course." + section.crn).addClass('conflict');
			}

			add_section_to_calendar(conflicted_section);
		},
		mouseleave: function() {
			conflicted_section = get_section_data($(this).attr('rel'));
			var conflicts = get_conflicted_classes(conflicted_section);

			$("#calendar .course." + conflicted_section.crn).remove();

			$("#calendar .course.conflict").removeClass('conflict');
		}
	});

	$("#schedule-conflicts .course").live('click', function() {
		conflicted_section = get_section_data($(this).attr('rel'));
		var conflicts = get_conflicted_classes(conflicted_section);

		for(var i = 0; i < conflicts.length; i++) {
			var section = conflicts[i];

			$("#calendar .course." + section.crn + ":first").appendTo("#schedule-conflicts").attr('style', '');
			$("#calendar .course." + section.crn).remove();
			$("#schedule-courses .course." + section.crn).remove();
		}

		$(this).appendTo("#schedule-courses");

	});

	$("#schedule-courses .course").live('click', function() {
		$(this).appendTo("#schedule-conflicts");
		$("#calendar ." + $(this).attr('rel')).remove();
	});


	$(".add-section").click(function() {
		$("#course-col").show();
	});
	$(".cancel").click(function() {
		$("#course-col").hide();
	});
});

function get_conflicted_classes(conflicted_section) {
	conflicts = []
	for(var i = 0; i < schedule_data.sections.length; i++) {
		var section = schedule_data.sections[i];
		
		if(section == conflicted_section) continue;
		if(section_conflict(section, conflicted_section) == true) {
			conflicts.push(section)
		}

		if(section.department == conflicted_section.department && section.courseNumber == conflicted_section.courseNumber) {
			conflicts.push(section);
		}
	}

	return conflicts
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

			$("#calendar").append("<div rel='" + section.crn + "' class='course " + section.crn + " " + day + "'></div>")
		}
	}
	
	$("#calendar ." + section.crn).append("<span class='title'>" + section.title + "</span><span class='instructor'>" + section.instructor + "</span>").css("height", time.endPixel-time.startPixel).css("top", time.startPixel + "px");
}

function get_data(crns, callback) {
	$.get("/schedules.json", {
			crns: crns
	}, function(data) {
		window.schedule_data = data;

		window.schedule_data.up_to_date = true;

		callback();
	});
}

function draw_schedule_links() {
	$("#schedules a").remove();
	for(var s = 0; s < window.schedule_data.schedules.length; s++) {
		$("#schedules").append("<a href='#' rel='" + s + "'>Schedule " + s + "</a>");
	}
}

function draw_schedule(schedule_index) {
	var schedule = window.schedule_data.schedules[schedule_index];

	$("#calendar .course").remove();
	$("#schedule-courses").empty();
	$("#schedule-conflicts").empty();

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
	$("#schedule-courses").append("<div rel='" + course.crn + "' class='course " + course.crn + "'><span class='title'>" + course.title + "</span> <span class='instructor'>" + course.instructor + "</div>");
}

function add_to_conflicts_list(course) {
	$("#schedule-conflicts").append("<div rel='" + course.crn + "' class='course " + course.crn + "'><span class='title'>" + course.title + "</span> <span class='instructor'>" + course.instructor + "</span></div>");
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
