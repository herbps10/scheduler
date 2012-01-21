class Scheduler
	attr_accessor :courses, :schedules

	def initialize
		@courses = CourseList.new
	end

	def schedule
		@schedules = []

		#while(@schedules.length == 0)
			combinations = []

			@courses.courses.each do |c|
				combinations.push c.sections
			end
			
			schedules = combinations[0].product(*combinations[1..combinations.length])

			schedules.each_with_index do |schedule, i|
				schedules[i] = Schedule.new(schedule)
			end

			@schedules = schedules.delete_if { |schedule| schedule.conflicted == true }
			
			schedules.each do |schedule|
				#schedule.print

				puts
			end
		#end
	end
end
