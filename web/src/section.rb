class Section
	attr_accessor :crn, :title, :instructor, :section, :time, :courseNumber, :department

	def initialize(crn)
		data = $redis.hgetall(RedisHelper::section(crn))

		@crn = crn
		@title = data["title"]
		@instructor = data["instructor"]
		@section = data["section"]
		@courseNumber = data["courseNumber"]
		@department = data["department"]
		@time = CourseTime.new(data["time"], data["days"])
	end

	def conflict? section
		return true if @time.conflict? section.time
		return false
	end
end
