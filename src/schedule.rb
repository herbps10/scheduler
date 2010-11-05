class Schedule
	attr_accessor :courses

	def initialize
		@courses = []
	end
	
	def clone
		cloned = Schedule.new
		cloned.courses = @courses.clone

		return cloned
	end

	def addCourse(course)
		return addCourseWithOverride(course, false)
	end

	def addCourseWithOverride(course, override)
		@courses.each do |existingCourse|
			if existingCourse.courseTimeConflict(course)
				return false if override == false
			end
		end

		@courses.push course

		return true
	end

	def checkForConflicts
		conflicts = []
		@courses.each do |c1|
			@courses.each do |c2|
				next if c1 == c2

				if c1.courseTimeConflict(c2)
					conflicts.push [c1, c2] if conflicts.include?([c2, c1]) == false
				end
			end
		end

		return conflicts
	end

	def eachCourse
		@courses.each do |course|
			yield course
		end
	end

	def removeCourse(department, number, section)
		oldLength = @courses.length
		@courses.delete_if { |course| course.department == department and course.number == number and course.section == section }

		return true if @courses.length < oldLength
		return false
	end

	def display
		@courses.each do |course|
			course.display
			puts
		end
	end

	def shortDisplay
		@courses.each { |course| course.shortDisplay }
	end

	def getCredits
		credits = 0
		@courses.each do |course|
			credits += course.credits.to_i
		end

		return credits
	end
end
