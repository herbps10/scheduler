require "src/course.rb"
require "src/courses.rb"
require "src/coursetime.rb"
require "src/functions.rb"
require "src/schedule.rb"
require "src/scheduler.rb"

class Course
	def graphName
		return @department.sub('&', '') + "_" + @number + "_" + @section
	end
end

files = Dir.glob("data/11/courses.geneseo.edu/spring/*.txt")

courses = Courses.new
files.each { |file| courses.parseFile(file) }

out = File.open('courses.net', 'w')

courses.each do |course|
	#out.puts(course.graphName)
	courses.each do |course2|
		next if(course2 == course)

		if(course.courseTimeConflict(course2))
			conflictStr = course.graphName + " " + course2.graphName
			out.puts(conflictStr)
		end
	end
end

out.close
