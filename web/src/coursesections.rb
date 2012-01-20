class CourseSections
	attr_accessor :sections

	def initialize(crns = nil)
		@sections = []
		if crns != nil
			crns.each do |crn|
				sections.push Section.new(crn)
			end
		end
	end

	def add section
		@sections.push section
	end

	def print
		@sections.each do |section|
			section.print
		end
	end

end
