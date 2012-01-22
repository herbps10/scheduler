class Schedule
	attr_accessor :sections, :conflicts

	def initialize(sections)
		@sections = sections
		@conflicts = []
	end
	
	def checkForConflicts
		conflicts = []
		sections = @sections.dup

		sections.each do |section1|
			sections.each do |section2|
				next if section1 == section2

				conflicts.push [section1, section2] if section1.department == section2.department and section1.courseNumber == section2.courseNumber
				conflicts.push [section1, section2] if section1.conflict? section2
			end

			sections.delete_if { |s| s == section1 }
		end

		return conflicts
	end

	def conflicted
		pairs = @sections.permutation(2).to_a

		pairs.each do |pair|
			return true if pair[0].department == pair[1].department and pair[0].courseNumber == pair[1].courseNumber
			return true if pair[0].conflict? pair[1]
		end
		
		return false
	end

	def getCredits
		credits = 0
		@sections.each { |s| credits += s.credits.to_i }

		return credits
	end

	def print
		@sections.each do |section|
			puts section.title + " " + section.section
		end
	end
end
