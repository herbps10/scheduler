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

out = File.open('courses.gv', 'w')

out.puts('strict Graph g {')

courses.each do |course|
	out.puts("\t" + course.graphName)
	courses.each do |course2|
		next if(course2 == course)

		if(course.courseTimeConflict(course2))
			conflictStr = "\t" + course.graphName + " -- " + course2.graphName
			out.puts(conflictStr)
		end
	end
end

out.puts('}')

out.close
