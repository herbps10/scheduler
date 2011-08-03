class RedisHelper
	def self.course(id)
		return "course:" + id.gsub(' ', '-')
	end

	def self.course_sections(id)
		return "course:sections:" + id.gsub(' ', '-')
	end

	def self.section(id)
		return "section:" + id
	end

	def self.department(id)
		return "department:" + id
	end
end
