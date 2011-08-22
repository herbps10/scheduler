class Scheduler
	def initialize
		@sections = []
		@schedules = nil
	end

	def addSection(section)
		@sections.push section
	end

	def addCourse(title)

	end

	def genSchedule(size)
		combinations = @sections.combination(size).to_a
		
		schedules = combinations.map { |sections| Schedule.new.addSections sections }

		schedules.delete_if { |schedule| schedule.checkForConflicts != [] }

		return schedules
	end

	def schedules
		if @schedules == nil
			@schedules = []
		else
			return @schedules
		end
		
		@schedules = []
		size = @sections.length
		while @schedules == [] && size >= 2
			puts size
			@schedules = genSchedule(size)
			size -= 1
		end

		puts @schedules.inspect

		return @schedules
	end
end
