class CourseTime
	attr_accessor :day, :startTimeInMinutes, :endTimeInMinutes

	# Expects the following format: 1:30pm-3:30pm
	# Breaks apart the time string and initializes the correct instance variables
	def setTime(time)
		@englishTime = time

		elements = time.split("-")
		@englishStartTime = elements[0]
		@englishEndTime = elements[1]

		@startTimeInMinutes = englishTimeToMinutes(@englishStartTime)
		@endTimeInMinutes = englishTimeToMinutes(@englishEndTime)
	end

	# Checks to see if the given course time conflicts with this course time
	def conflict?(time)
		return true if \
				(time.startTimeInMinutes <= @endTimeInMinutes && time.startTimeInMinutes >= @startTimeInMinutes) \
				or (time.endTimeInMinutes >= @startTimeInMinutes && time.endTimeInMinutes <= @endTimeInMinutes) \
				or (time.startTimeInMinutes > @startTimeInMinutes && time.endTimeInMinutes < @endTimeInMinutes) \
				or (time.startTimeInMinutes < @startTimeInMinutes && time.endTimeInMinutes > @endTimeInMinutes) \
				&& @day == time.day
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
end


