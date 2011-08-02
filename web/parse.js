var fs = require('fs')
var $ = require('jquery')
var db = require('./lib/redis-client.js')

var redis = db.createClient()

redis.flushdb

departments = [ "CSCI", "ACCT" ];

for(var department_index in departments) {
	var department = departments[department_index];
	fs.readFile("./data/" + department + ".html", 'utf8', function(err, data) {
		$("tr", data).each(function() {
			if($(this).attr("valign") != "middle" && $(this).children("td").length > 1) {
				course = {}
				$(this).children("td").each(function(index) {
					// CRN
					if(index == 1) {
						course.crn = $(this).text();
					}
					// Department
					else if(index == 2) {
						course.department = $(this).text();
					}
					// Course Number
					else if(index == 3) {
						course.courseNumber = $(this).text();
					}
					// Section
					else if(index == 4) {
						course.section = $(this).text();
					}
					// Credits
					else if(index == 6) {
						course.credits = $(this).text();
					}
					// Title
					else if(index == 7) {
						course.title = $(this).text();
					}
					// Days
					else if(index == 8) {
						course.days = $(this).text();
					}
					// Time
					else if(index == 9) {
						course.time = $(this).text();
					}
					// Capacity
					else if(index == 10) {
						course.capacity = $(this).text();
					}
					// Actual
					else if(index == 11) {
						course.actual = $(this).text();
					}
					// Remaining
					else if(index == 12) {
						course.remaining = $(this).text();
					}
					// Instructor
					else if(index == 16) {
						course.instructor = $(this).text();
					}
					// Location
					else if(index == 18) {
						course.location = $(this).text();
					}
				});


				for(var field in course) {
					if(field == "crn") {
						continue;
					}

					redis.hset(course.crn, field, course[field]);
				}

				redis.sadd(course.department, course.crn);
			}
		});
	});
}
