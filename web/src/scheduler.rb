class Scheduler
	attr_accessor :courses, :schedules, :sections

	def initialize
		@courses = CourseList.new
	end

	def schedule
		@schedules = []
		len = @courses.courses.length

		@sections = []
		@courses.courses.each do |c|
			@sections += c.sections
		end

		
		while(@schedules.length == 0)
			courses = @sections.combination(len).to_a

			courses.each do |combinations|

				combinations.map! { |c| [c] }
				schedules = combinations[0].product(*combinations[1..combinations.length])

				schedules.each_with_index do |schedule, i|
					schedules[i] = Schedule.new(schedule)
				end

				@schedules += schedules.delete_if { |schedule| schedule.conflicted == true }

				schedules.each do |schedule|
					schedule.conflicts = @sections - schedule.sections.flatten
				end
			end

			len = len - 1
		end
	end
end
