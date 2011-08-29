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

	def product(index, sets)
		if index == sets.length - 1
			return sets[index]
		end

		ret = []
		sets[index].each do |element|
			product(index + 1, sets).each do |e|
				if element.conflict?(e) == false and element.sameCourse?(e) == false
					ret.push [element] + [e]
				end
			end
		end

		ret.map! { |r| r.flatten.sort_by { |s| s.crn } }
		
		puts ret.length

		return ret
	end

	def subtract(list1, list2)
		if list1.kind_of? Array
			list1.flatten! 
		else
			list1 = [list1]
		end

		if list2.kind_of? Array
			list2.flatten!
		else
			list2 = [list2]
		end


		ret = []
		list1.each do |s1|
			included = false
			list2.each do |s2|
				next if s1 == s2

				if s1.department == s2.department and s1.courseNumber == s2.courseNumber
					included = true
				end
			end

			ret.push s1 if included == true

			#list1.delete_if { |l| l == s1 }
		end
		
		return ret
	end

	def intersect(list1, list2, crn = false)
		if list1.kind_of? Array
			list1.flatten! 
		else
			list1 = [list1]
		end

		if list2.kind_of? Array
			list2.flatten!
		else
			list2 = [list2]
		end


		ret = []

		list1.each do |s1|
			included = false
			list2.each do |s2|
				if crn == true
					if s1.crn == s2.crn
						ret.push s2
					end
				else
					if s1.department == s2.department and s1.courseNumber == s2.courseNumber
						ret.push s2
					end
				end
			end

		end

		return ret
	end

	def intersect_crn(list1, list2)
		intersect(list1, list2, true)
	end

	def same_course(arr)
		return false if arr.flatten != arr
		return false if arr.length == 0

		arr.each do |s1|
			arr.each do |s2|
				next if s1 == s2

				puts s1.department + " " + s2.department
				return false if s1.department != s2.department
				return false if s1.department == s2.department && s1.courseNumber != s2.courseNumber
			end
		end

		return true
	end

	def condense_schedules(options)
		schedules = product(0, options)

		return [schedules] if same_course(schedules)

		return [schedules] if schedules.length == 1

		i = 0
		while true
			replacement = []
			schedules.each do |s1|
				schedules.each do |s2|
					next if s1 == s2

=begin
					puts "s1"
					puts s1.inspect
					puts
					puts "s2"
					puts s2.inspect
					puts
					puts "intersect"
					puts intersect_crn(s1, s2).inspect
					puts
					puts "subtract s1 s2"
					puts subtract(s1, s2).inspect
					puts
					puts "subtract s2 s1"
					puts subtract(s2, s1).inspect
					puts
					puts
					puts
=end

					if subtract(s1, s2).length == 1
						replace = intersect_crn(s1, s2) + [[subtract(s1, s2) + subtract(s2, s1)].flatten.sort_by { |s| s.crn }]

						replacement.push replace
					end
				end

				options.delete_if { |s| s == s1 }
			end

			break if replacement.length == 0


			schedules = replacement.clone
			i += 1
		end

		schedules.uniq!

		return schedules
	end

	def genSchedules(size)
		# Gives us an array of arrays containing the different section options
		# The sections of the courses are already wrapped in an array, but we 
		# need to wrap the individual sections into an array
		all_sections = (@courses | @sections.map { |s| [s] })

		schedules = []

		all_sections.combination(size).to_a.each do |options|
			schedules += condense_schedules(options)
=begin
			schedules += options.reduce { |initial, course| initial.product(course) } \
				.map { |combo| 
					if combo.is_a? Array
						combo.flatten
					else
						combo
					end
				} \
				.map { |sections| Schedule.new.addSections sections }

			schedules.delete_if { |schedule| schedule.checkForConflicts != [] }
=end
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

		sum = 0
		@courses.each { |course| sum += course.length }

		size = @sections.length + @courses.length

		while @schedules == []
			@schedules = genSchedules(size)

			size -= 1
			break if size == 0
		end

		return @schedules
	end
end
