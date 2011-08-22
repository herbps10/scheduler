class Schedule
	attr_accessor :sections

	def addSections sections
		@sections += sections.map do |section|
			if section.is_a? Section
				section
			else
				Section.new section # we've been given a CRN, so create a new section object
			end
		end

		return self
	end

	def initialize
		@sections = []
		return self
	end
	
	def checkForConflicts
		conflicts = []
		sections = @sections.dup

		sections.each do |section1|
			sections.each do |section2|
				next if section1 == section2

				conflicts.push [section1, section2] if section1.conflict? section2
			end

			sections.delete_if { |s| s == section1 }
		end

		return conflicts
	end

	def getCredits
		credits = 0
		@sections.each { |s| credits += s.credits.to_i }

		return credits
	end
end
