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

		puts @crn + " " + @title
	end

	def conflict? section
		if section.kind_of?(Array) == true
			section.each do |s|
				if s.kind_of?(Array) == true
					s.each do |a|
						@times.each do |time|
							return true if time.conflict?(a.times) == true
						end

						return false
					end
				else
					@times.each do |time|
						return true if time.conflict?(s.times) == true
					end

					return false
				end
			end

			return false
		else
			@times.each do |time|
				return true if time.conflict?(section.times)
			end
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
