class Course
	attr_accessor :department, :number, :courseTimes, :section, :credits, :instructor, :capacity, :enrolled

	def initialize
		@courseTimes = []
	end
	
	def addCourseTime(time)
		@courseTimes.push time
	end

	def display
		shortDisplay
		@courseTimes.each { |t| puts t.day + " " + t.getEnglishTime }
	end

	def shortDisplay
		puts @department + " " + @number + " Section " + @section + ", " + @instructor
	end

	# Checks to see if the given course conflicts with this course
	def courseTimeConflict(course)
		@courseTimes.each do |myCourseTime|
			course.getCourseTimes.each do |yourCourseTime|
				return true if myCourseTime.conflict?(yourCourseTime)
			end
		end

		return false
	end

	def getCourseTimes
		return @courseTimes
	end
end
