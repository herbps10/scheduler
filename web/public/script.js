var data;

$(document).ready(function() {
	$.getJSON('/courses.json', function(d) {
		data = d;
		for(var department_index in data.departments) {
			var department = data.departments[department_index];

			$(".departments > ul").append("<li>" + department.title + "</li>").append("<div class='courses'><ul></ul></div>");

			for(var course_index in department.courses) {
				var course = department.courses[course_index];

				$(".courses:last ul").append("<div class='course'><li>" + course.title + "</li><div class='sections'><ol></ul></div></div>");

				for(var section_index in course.sections) {
					var section = course.sections[section_index];

					$(".sections:last ol").append("<li>" + section.crn + "</li>");
				}
			}
		}
	});
});
