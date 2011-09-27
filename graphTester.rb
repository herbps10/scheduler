require "src/course.rb"
require "src/courses.rb"
require "src/coursetime.rb"
require "src/functions.rb"
require "src/schedule.rb"
require "src/scheduler.rb"

files = Dir.glob("data/*.txt")

courses = Courses.new
files.each { |file| courses.parseFile(file) }

scheduler = Scheduler.new(courses)

c1 = courses.getCourse("CSCI", "142", "02")
c2 = courses.getCourse("CSCI", "240", "01")

scheduler.addFixedCourse(courses.getCourse("BIOL", "119", "01"))
scheduler.addFixedCourse(courses.getCourse("CSCI", "142", "01"))
scheduler.addFixedCourse(courses.getCourse("CSCI", "142", "02"))
scheduler.addFixedCourse(courses.getCourse("MATH", "326", "01"))

schedules = scheduler.graphGenerateSchedules()

=begin
if schedules.length == 0
	puts "No schedules found"
end

schedules.length.times do |i|
	puts "Schedule " + i.to_s + ": "
	schedules[i].display
	puts
end
=end
