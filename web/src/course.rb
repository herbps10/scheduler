class Course
	attr_accessor :title, :sections, :courseNumber, :description, :department
	
	def initialize(title)
		@sections = SectionList.new

		data = $redis.hgetall(RedisHelper::course(title))

		@title = data["title"]
		@courseNumber = data["courseNumber"]
		@description = data["description"]
		@department = data["department"]

		$redis.smembers(RedisHelper::course_sections(@title)).each do |crn|
			@sections.add Section.new(crn)
		end
	end

	def courseSection? section
		return false if section.is_a?(Section) == false

		return true if section.department == @department and section.courseNumber == @courseNumber
		return false
	end

	def sameCourse? course
		return false if course.is_a?(Course) == false

		return true if course.department == @department && section.courseNumber == @courseNumber
		return false
	end
end
