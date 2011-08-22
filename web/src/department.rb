class Department
	attr_accessor :courses, :title

	def initialize(department)
		@title = department
		@courses = []

		$redis.zrange(RedisHelper::department(@title), 0, -1).each do |title|
			@courses.push Course.new(title)
		end
	end

	def each
		@courses.each do |course|
			yield course
		end
	end
end
