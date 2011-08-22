class Course
	attr_accessor :title, :sections, :courseNumber
	
	def initialize(title)
		@sections = []

		data = $redis.hgetall(RedisHelper::course(title))

		@title = data["title"]
		@courseNumber = data["courseNumber"]

		$redis.smembers(RedisHelper::course_sections(@title)).each do |crn|
			@sections.push Section.new(crn)
		end
	end
end
