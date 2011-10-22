class Section
	attr_accessor :crn, :title, :instructor, :section, :time, :courseNumber, :department, :credits, :conflicted

	def initialize(crn)
		data = $redis.hgetall(RedisHelper::section(crn))

		@crn = crn
		@title = data["title"]
		@instructor = data["instructor"]
		@section = data["section"]
		@courseNumber = data["courseNumber"]
		@department = data["department"]
		@credits = data["credits"]
		@time = CourseTime.new(data["time"], data["days"])
		@conflicted = false
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

	def sameSection? section
		if section.kind_of?(Array) == true
			section.each do |s|
				return true if s.crn == @crn
			end

			return false
		else
			return true if section.crn == @crn
			return false
		end
	end

	def clone
		return Marshal.load(Marshal.dump(self))
	end
end
