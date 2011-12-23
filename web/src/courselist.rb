class CourseList
	attr_accessor :courses

	def initialize
		@courses = []
	end

	def contains section
		return false if section.is_a?(Section) == false

		@courses.each { |c| return true if section.courseSection?(c) }
	end

	def add course
		@courses.push course
	end
end


