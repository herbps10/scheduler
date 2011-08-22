class Everything
	attr_accessor :departments

	def initialize()
		@departments = []
		
		$redis.smembers(RedisHelper::departments).sort.each do |department|
			@departments.push Department.new(department)
		end
	end
end
