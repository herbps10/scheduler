class Array
	def conflict?(section)
		self.each do |e|
			return true if e.conflict?(section) == true
		end

		return false
	end

	def all_length
		sum = 0
		self.each do |e|
			if e.kind_of? Array
				sum += e.length 
			end
		end

		sum = self.length if self.length > 0 and sum == 0

		return sum
	end

	def contains_arrays
		self.each do |e|
			return true if e.kind_of? Array
		end

		return false
	end

	def conflicted=(conflict)
		self.each do |e|
			e.conflicted = conflict
		end
	end

	def conflicted
		self.each do |e|
			return true if e.conflicted
		end

		return false
	end

	def all_conflicted
		self.each do |e|
			return false if e.conflicted == false
		end

		return true
	end

	def addSection(section)
		self.each_with_index do |course, course_index|
			course = [course] if course.kind_of?(Array) == false
			if(course[0].sameCourse?(section))
				if self[course_index].kind_of?(Array) == false
					if(self[course_index].sameCourse?(section) == false)
						self[course_index] = [self[course_index]]
					end
				end
				
				if(self[course_index].sameCourse?(section) == false)
					self[course_index] += section
				end
				return
			end
		end

		self.push section
		return
	end

	def deep_clone
		n = []
		self.each do |e|
			n.push(e.clone)
		end

		return n
	end

	def sameCourse?(section)
		self.each do |e|
			return true if e.sameCourse?(section)
		end

		return false
	end
end

class Scheduler
	attr_accessor :all_sections

	def initialize
		@sections = []
		@courses = []
		@schedules = nil
		@all_sections = []
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
				if element.conflict?(e)== false
					if e.contains_arrays == true
						ret.push([element] + e)
					else
						ret.push [element] + [e]
					end
				end
			end
		end

		return ret
	end

	def has_conflict(sections)
		sections = sections.clone
		return false if sections.length <= 1

		sections.each do |s1|
			sections.each do |s2|
				next if s1 == s2

				return true if s1.conflict? s2
			end

			sections.delete_if { |s| s == s1 }
		end

		return false
	end

	def course_product(sections)
		combinations = []
		(1..sections.length).to_a.each do |size|
			combinations += sections.combination(size).to_a.delete_if { |s| has_conflict(s) }
		end

		return combinations
	end

	def genSchedules(size)
		# Gives us an array of arrays containing the different section options
		# The sections of the courses are already wrapped in an array, but we 
		# need to wrap the individual sections into an array
		@all_sections = (@courses | @sections.map { |s| [s] })

		all = []

		puts "All Sections:"
		puts @all_sections.inspect.gsub('>', "\n")

		@all_sections.combination(size).to_a.each do |options|
			puts "Options: "
			puts options.inspect.gsub(">", "\n")
			puts "\n\n"

			course_combinations = []

			options.each do |course|
				course_combinations += [course_product(course)]
			end

			all += product(0, course_combinations).sort_by { |s| s.all_length }.reverse

=begin
			all.delete_if { |s| 
				s.all_length != all[0].all_length
			}
=end
		end

		return [] if all == []

		return all
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

		size = sum if(@courses.length == 1)

		while @schedules == []
			@schedules = genSchedules(size)

			size -= 1
			break if size == 0
		end

		if @sections.length + @courses.length == 1
			@schedules = [@schedules]
		end

		@schedules.each_with_index do |schedule, index|
			diff = (@all_sections - schedule)

			diff.each do |section|
				s2 = section.deep_clone
				s2.conflicted = true
				schedule.addSection(s2)
			end

			@schedules[index] = schedule.sort_by { |s| 
				if s.kind_of? Array
					s[0].crn
				else
					s.crn
				end
			}
		end

		return @schedules
	end
end
