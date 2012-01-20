class SectionList
	attr_accessor :sections

	def initialize(crns = false)
		@sections = []

		if(crns != false)
			crns.each do |crn|
				add Section.new(crn)
			end
		end
	end

	def add section
		@sections.push section
	end

	def each
		@sections.each do |section|
			yield section
		end
	end

	def [](index)
		return @sections[index]
	end
end
