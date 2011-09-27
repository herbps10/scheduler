=begin
This class takes in courses you want to take and figures out all the possible schedules
=end

class Scheduler
	def initialize(courses)
		@courses = courses

		@fixedCourses = []
		@flexibleCourses = []

		@fixedCoursesIgnoreConflicts = []

		@schedules = []
	end

	# A fixed course is one that is not negotiable, it must be in every schedule.
	def addFixedCourse(course)
		@fixedCourses.push(course)
	end

	def addFixedCourseIgnoreConflicts(course)
		@fixedCoursesIgnoreConflicts.push(course)
	end

	# A flexible course is one where the section doesn't matter
	def addFlexibleCourse(department, number)
		course = FlexibleCourse.new
		course.department = department
		course.number = number
		
		@flexibleCourses.push(course)
	end

	def generateSchedules(showAllOptions)
		baseSchedule = Schedule.new

		@fixedCourses.each do |course|
			baseSchedule.addCourse(course)
			puts course.department
		end

		schedules = addLevel(baseSchedule, 0, showAllOptions)

		@fixedCoursesIgnoreConflicts.each do |course|
			schedules.each do |schedule|
				schedule.addCourseWithOverride(course, true)
			end
		end

		return schedules
	end

	def addLevel(schedule, depth, showAllOptions)
		if depth == @flexibleCourses.length
			return [schedule]
		end

		sections = @courses.coursesByDepartmentAndNumber(@flexibleCourses[depth].department, @flexibleCourses[depth].number)
		
		schedules = []

		sections.each do |section|
			alternativeSchedule = schedule.clone
			
			if showAllOptions == true
				alternativeSchedule.addCourse(section)
				schedules.concat(addLevel(alternativeSchedule, depth + 1, showAllOptions))
			else
				if alternativeSchedule.addCourse(section)
					schedules.concat(addLevel(alternativeSchedule, depth + 1, showAllOptions))
				else
					next
				end
			end
		end

		return schedules
	end

	def graphGenerateSchedules
		# Check to see if there are any edges
		highDegree = 0
		@fixedCourses.each do |course1|
			@fixedCourses.each do |course2|
				next if course1 == course2

				if course1.courseTimeConflict course2
					conflict = true
					break
				end
			end

			break if conflict == true
		end

		if conflict == false
			puts "No conflicts"
			return
		end

		

		return []
	end
end

class FlexibleCourse
	attr_accessor :department, :number
end
