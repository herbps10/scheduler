require 'rubygems'
require 'redis'
require 'nokogiri'

require 'redishelper.rb'

class Saver
	@@fields = :crn, :department, :courseNumber, :section, :credits, :title, :days, :time, :capacity, :actual, :remaining, :instructor, :location
	@@fields.each { |field| attr_accessor field }

	def save_course
		$redis.hset(RedisHelper::course(@title), 'title', @title)
		$redis.hset(RedisHelper::course(@title), 'credits', @credits)

		$redis.sadd(RedisHelper::department(@department), @title.gsub(' ', '-'))

		save_section
	end

	def save_section
		$redis.hset(RedisHelper::section(@crn), 'section', @section)
		$redis.hset(RedisHelper::section(@crn), 'title', @title)
		$redis.hset(RedisHelper::section(@crn), 'instructor', @instructor)
		$redis.hset(RedisHelper::section(@crn), 'location', @location)

		$redis.sadd(RedisHelper::course_sections(@title), @crn)
	end

	def save
		@@fields.each do |field|
			next if field == :crn

			$redis.hset(@crn, field, instance_variable_get("@" + field.to_s))
		end

	end
end

$redis = Redis.new

$redis.flushdb

departments = [ "ACCT", "ANTH", "ARTH", "ARTS", "ASTR", "BIOL", "BLKS", "COMN", "CDSC", "DANC", "EDUC", "ENVR", "CHEM", "ECON", "ENGL", "CSCI", "GEOG", "GSCI", "HIST", "H&PE", "HONR", "HUMN", "INTD", "MATH", "PHYS", "THEA", "WRIT", "SOCI", "PLSC", "SPAN", "FREN", "JAPN", "GERM", "LATN", "ITAL", "RUSS", "CHIN", "ARBC", "MGMT", "MUSC", "PHIL", "PSYC", "WMST" ]

departments.each do |department|
	doc = Nokogiri::HTML(File.open("data/#{department}.html").read)

	course = Saver.new
	valid_row = false
	index = 0

	previous_course = nil

	doc.css('tr td').each do |cell|
		next if cell.content == ''

		if /[0-9]{5}/ =~ cell.content
			valid_row = true
			index = 0
		end

		next if valid_row == false

		if(index == 0) 		
			course.crn = cell.content
		elsif(index == 1) 
			course.department = cell.content
		elsif(index == 2)	
			course.courseNumber = cell.content
		elsif(index == 3) 	
			course.section = cell.content
		elsif(index == 4) 	
			course.credits = cell.content
		elsif(index == 6) 	
			course.title = cell.content
		elsif(index == 7) 	
			course.days = cell.content
		elsif(index == 8) 	
			course.time = cell.content
		elsif(index == 9) 	
			course.capacity = cell.content
		elsif(index == 10) 	
			course.actual = cell.content
		elsif(index == 11) 	
			course.remaining = cell.content	
		elsif(index == 15) 	
			course.instructor = cell.content	
		elsif(index == 17) 	
			course.location = cell.content 

			if previous_course == nil

			elsif previous_course.title != course.title
				course.save_course
			else
				course.save_section
			end

			previous_course = course.dup
			valid_row = false
		end


		index += 1
	end
end
