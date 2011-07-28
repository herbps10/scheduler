require 'sinatra'
require 'redis'

$redis = Redis.new

class Section
	attr_accessor :crn, :title, :instructor, :section

	def initialize(crn)
		data = $redis.hgetall(crn)

		@crn = crn
		@title = data["title"]
		@instructor = data["instructor"]
		@section = data["section"]
	end
end

class Course
	attr_accessor :title, :sections
	
	def initialize(crn)
		@sections = []

		data = $redis.hgetall(crn)

		@title = data["title"]
	end

	def addSection(section)
		@sections.push section
	end
end

class Department
	attr_accessor :courses

	def initialize(department)
		@department = department
		@courses = []

		last_section = nil
		current_course = nil

		$redis.smembers(@department).each do |crn|
			section = Section.new(crn)

			if current_course == nil or (last_section != nil and last_section.title != section.title)
				@courses.push current_course if current_course != nil

				current_course = Course.new(crn)
				current_course.addSection(section)
			else
				current_course.addSection(section)
			end
			
			last_section = section
		end
	end

	def each
		@courses.each do |course|
			yield course
		end
	end
end

get '/' do
	@department = Department.new("ACCT")

	erb :index
end
