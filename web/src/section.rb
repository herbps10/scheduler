class Section
	attr_accessor :crn, :title, :instructor, :section, :times, :courseNumber, :department, :credits, :conflicted

	def initialize(crn)
		data = $redis.hgetall(RedisHelper::section(crn))

		@crn = crn
		@title = data["title"]
		@instructor = data["instructor"]
		@section = data["section"]
		@courseNumber = data["courseNumber"]
		@department = data["department"]
		@credits = data["credits"]

		@times = []
		data["time"].split(',').each_with_index do |time, index|
			@times.push CourseTime.new(time, data["days"].split(',').at(index))
		end

		@conflicted = false
	end

	def sameCourse? section
		return true if section.courseNumber == @courseNumber && section.department == @department
		return false
	end

	def clone
		return Marshal.load(Marshal.dump(self))
	end

	def print
		puts "#{@crn} #{@department} #{@courseNumber} #{@title} Section #{@section}"
	end

	def conflict? section
		@times.each do |time|
			return true if time.conflict?(section.times)
		end
		
		return false
	end
end
