$(document).ready(function() {
	$.get("/schedules.json", {
			crns: ['55374', '50608', '54582', '50371']
	}, function(data) {
		draw(data);
	});
});

/*
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
*/

$(document).ready(function() {
});

function draw(data) {
	console.log(data);
	var schedule = data.schedules[0];

	for(i in schedule.courses) {
		var course = schedule.courses[i];

		for(t in course.times) {
			var time = course.times[t];

			for(d in time.days) {
				var day = time.days[d];

				if(day == "M") day = "mon"
				if(day == "T") day = "tue"
				if(day == "W") day = "wed"
				if(day == "R") day = "thu"
				if(day == "F") day = "fri"

				$("#calendar").append("<div class='course " + course.crn + " " + day + "'></div>")

			}
		}
		
		$("." + course.crn).append(course.title).css("height", time.endPixel-time.startPixel).css("top", time.startPixel + "px");
	}
}
