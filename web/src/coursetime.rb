class CourseTime
	attr_accessor :days, :startTimeInMinutes, :endTimeInMinutes

	def tba
		@tba
	end

	def initialize(time, days)
		if time != nil and days != nil
			@days = days.split('')
			setTime(time)
		else
			raise "time and days are nil in coursetime initializer"
		end
	end

	# Expects the following format: 1:30pm-3:30pm
	# Breaks apart the time string and initializes the correct instance variables
	def setTime(time)
		@tba = false;
		if time == "TBA"
			@tba = true
			return
		end

		@englishTime = time

		elements = time.split("-")
		@englishStartTime = elements[0].gsub(' ', '')
		@englishEndTime = elements[1].gsub(' ', '')

		@startTimeInMinutes = englishTimeToMinutes(@englishStartTime)
		@endTimeInMinutes = englishTimeToMinutes(@englishEndTime)
	end

	# Checks to see if the given course time conflicts with this course time
	def conflict?(time)
		return false if @tba == true
		return false if time.tba == true

		return true if \
				((time.startTimeInMinutes <= @endTimeInMinutes && time.startTimeInMinutes >= @startTimeInMinutes) \
				or (time.endTimeInMinutes >= @startTimeInMinutes && time.endTimeInMinutes <= @endTimeInMinutes) \
				or (time.startTimeInMinutes > @startTimeInMinutes && time.endTimeInMinutes < @endTimeInMinutes) \
				or (time.startTimeInMinutes < @startTimeInMinutes && time.endTimeInMinutes > @endTimeInMinutes)) \
				and (@days & time.days).length > 0
		return false
	end

	# Converts a time in english, as found in the course listing files, into the number of minutes after midnight.
	def englishTimeToMinutes(englishTime)
		minutes = 0
		if(englishTime[(englishTime.length - 2)..englishTime.length] == "pm")
			minutes = 720
		end

		elements = englishTime[0..(englishTime.length - 3)].split(":")

		if(elements[0] != "12")
			minutes += 60 * (elements[0].to_i)
		end

		minutes += elements[1].to_i

		return minutes
	end

	def getEnglishTime
		@englishTime
	end

	def uniqueID
		id = 0
		
		id += ("MTWRF".index(@day) + 1) * 1000000
		id += @startTimeInMinutes * 1000
		id += @endTimeInMinutes
	end

	def prettyTime
		return "TBA" if @tba == true
		return @englishTime.sub(' ', '')
	end

	def prettyDays
		return @days.join('')
	end
end
