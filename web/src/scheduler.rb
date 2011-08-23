class Scheduler
	def initialize
		@sections = []
		@courses = []
		@schedules = nil
	end

	def addSections(sections)
		if sections.is_a? Array
			sections.each { |section| addSection(section) }
		else
			addSection(sections)
		end
	end

	def addSection(section)
		# look to see if this section belongs to a course that is already in the courses array
		@courses.each_index do |i|
			if @courses[i][0].courseNumber == section.courseNumber and @courses[i][0].department == section.department
				@courses[i].push section 

				
				return
			end
		end

		# pick out sections that are of the same course
		course_sections = @sections.select { |s| s.courseNumber == section.courseNumber and s.department == section.department }

		if course_sections == []
			@sections.push section
		else
			@courses.push course_sections + [section]
			@sections -= course_sections
		end
	end

	def genSchedule(size)
		options = (@sections.map { |s| [s] } | @courses)

		schedules = []
		options.combination(size).each do |option|
			schedules += option.reduce { |initial, course| initial.product(course) } \
				.map { |combo| 
					if combo.is_a? Array
						combo.flatten
					else
						combo
					end
				} \
				.map { |sections| Schedule.new.addSections sections }

			schedules.delete_if { |schedule| schedule.checkForConflicts != [] }
		end

		return schedules
	end

	def schedules
		if @schedules == nil
			@schedules = []
		else
			return @schedules
		end
		
		@schedules = []
		size = @sections.length + @courses.length

		while @schedules == [] && size >= 1
			@schedules = genSchedule(size)
			size -= 1
		end


		return @schedules
	end
end
