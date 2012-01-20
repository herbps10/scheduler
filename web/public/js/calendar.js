var data = {
	schedules: [
		{
			courses: [
				{
					crn: 11284,
					title: "ELA",
					startTime: "8:00am",
					endTime: "8:50am",
					day: "tue",

					startPixel: 0,
					endPixel: 60
				},
				{
					crn: 11285,
					title: "Humanities",
					startTime: "10:00am",
					endTime: "10:50am",
					day: "mon",

					startPixel: 61,
					endPixel: 121 
				},
				{
					crn: 11286,
					title: "Humanities",
					startTime: "10:00am",
					endTime: "10:50am",
					day: "wed",

					startPixel: 122,
					endPixel: 182
				},
                {
					crn: 11288,
					title: "Humanities",
					startTime: "10:00am",
					endTime: "10:50am",
					day: "thu",

					startPixel: 122,
					endPixel: 182
				},
				{
					crn: 11289,
					title: "ELA",
					startTime: "8:00am",
					endTime: "8:50am",
					day: "fri",

					startPixel: 183,
					endPixel: 340
				}

			]
		}
	]
}

$(document).ready(function() {
	draw(data);
});

function draw(data) {
	var schedule = data.schedules[0];

	for(i in schedule.courses) {
		var course = schedule.courses[i];

		$("#calendar").append("<div id='" + course.crn + "' class=' course " + course.day + "'></div>")

		$("#" + course.crn).append(course.title).css("height",course.endPixel-course.startPixel).css("top", course.startPixel + "px");
	}
}
