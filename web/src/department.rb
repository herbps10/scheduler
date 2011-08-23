class Department
	attr_accessor :courses, :title

	def initialize(department)
		@department = department
		@title = $redis.get(RedisHelper.department_title(department))
		@courses = []

		$redis.zrange(RedisHelper::department(@department), 0, -1).each do |title|
			@courses.push Course.new(title)
		end
	end

	def each
		@courses.each do |course|
			yield course
		end
	end
end
