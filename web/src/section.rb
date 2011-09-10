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
		if section.kind_of?(Array) == true
			section.each do |s|
				if s.kind_of?(Array) == true
					s.each do |a|
						return true if @time.conflict?(a.time) == true
					end
				else
					return true if @time.conflict?(s.time) == true
				end
			end

			return false
		else
			return true if @time.conflict? section.time
			return false
		end
	end

	def sameCourse? section
		if section.kind_of?(Array) == true
			section.each do |s|
				return true if s.department == @department and s.courseNumber == @courseNumber
			end

			return false
		else
			return true if section.department == @department and section.courseNumber == @courseNumber
			return false
		end
	end
end
