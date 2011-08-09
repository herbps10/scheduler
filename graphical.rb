require "src/course.rb"
require "src/courses.rb"
require "src/coursetime.rb"
require "src/functions.rb"
require "src/schedule.rb"
require "src/scheduler.rb"

files = ["data/cs.txt", "data/bio.txt", "data/math.txt"]

courses = Courses.new
files.each { |file| courses.parseFile(file) }

=begin
scheduler = Scheduler.new(courses)

scheduler.addFixedCourse(courses.getCourse("BIOL", "119", "01"))
scheduler.addFixedCourse(courses.getCourse("CSCI", "142", "02"))

scheduler.addFlexibleCourse("MATH", "326")
scheduler.addFlexibleCourse("CSCI", "230")

#scheduler.addFlexibleCourse("MATH", "233")
#scheduler.addFlexibleCourse("CSCI", "120")

schedules = scheduler.generateSchedules(true)
=end

Shoes.app :width => 300, :height => 200 do
	@courses = list_box :items => [] do

	end

	@departments = list_box :items => ["CSCI", "MATH", "BIO"] do |list|
		departmentCourses = courses.coursesByDepartment(list.text)

		departmentCourses.each do |c|
			@courses.items.push(c.number)
		end

		@courses.items = ["Hello WOrld"]
	end
end
