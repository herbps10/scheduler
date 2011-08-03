require "src/course.rb"
require "src/courses.rb"
require "src/coursetime.rb"
require "src/functions.rb"
require "src/schedule.rb"
require "src/scheduler.rb"

files = Dir.glob("data/11/courses.geneseo.edu/spring/*.txt")

courses = Courses.new
files.each { |file| courses.parseFile(file) }

scheduler = Scheduler.new(courses)

#scheduler.addFixedCourse(courses.getCourse("BIOL", "119", "01"))
#scheduler.addFixedCourse(courses.getCourse("CSCI", "142", "01"))
#jscheduler.addFixedCourse(courses.getCourse("CSCI", "142", "02"))

# Modeling biological systems
scheduler.addFixedCourse(courses.getCourse("MATH", "340", "01"))
scheduler.addFixedCourse(courses.getCourse("MATH", "340", "02"))

scheduler.addFixedCourse(courses.getCourse("ANTH", "101", "01"))

scheduler.addFlexibleCourse("MATH", "326")
scheduler.addFlexibleCourse("CSCI", "230")
#scheduler.addFlexibleCourse("BIOL", "116")

schedules = scheduler.generateSchedules(false)

if schedules.length == 0
	puts "No schedules found"
end

schedules.length.times do |i|
	puts "Schedule " + i.to_s + ": "
	schedules[i].display
	puts
end
