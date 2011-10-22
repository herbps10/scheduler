require 'rubygems'
require 'redis'
require 'nokogiri'

require 'redishelper.rb'

class Saver
	@@fields = :crn, :department, :courseNumber, :section, :credits, :title, :days, :time, :capacity, :actual, :remaining, :instructor, :location, :time_id
	@@fields.each { |field| attr_accessor field }

	def save_course
		$redis.hset(RedisHelper::course(@title), 'title', @title)
		$redis.hset(RedisHelper::course(@title), 'credits', @credits)
		$redis.hset(RedisHelper::course(@title), 'courseNumber', @courseNumber);

		$redis.zadd(RedisHelper::department(@department), @courseNumber.to_i, @title.gsub(' ', '-'))

		save_section
	end

	def save_section
		$redis.hset(RedisHelper::section(@crn), 'section', @section)
		$redis.hset(RedisHelper::section(@crn), 'department', @department);
		$redis.hset(RedisHelper::section(@crn), 'courseNumber', @courseNumber);
		$redis.hset(RedisHelper::section(@crn), 'title', @title)
		$redis.hset(RedisHelper::section(@crn), 'instructor', @instructor)
		$redis.hset(RedisHelper::section(@crn), 'location', @location)
		$redis.hset(RedisHelper::section(@crn), 'credits', @credits)
		$redis.hset(RedisHelper::section(@crn), 'time', @time)
		$redis.hset(RedisHelper::section(@crn), 'days', @days)

		$redis.sadd(RedisHelper::time(@days, @time), @crn);

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

departments = { "ACCT" => "Accounting", 
		"ANTH" => "Anthropology",
		"ARTH" => "Art History",
		"ARTS" => "Art",
		"ASTR" => "Astronomy",
		"BIOL" => "Biology",
		"BLKS" => "Black Studies",
		"COMN" => "Communication",
		"CDSC" => "Speech Pathology",
		"DANC" => "Dance",
		"EDUC" => "Education",
		"ENVR" => "Environmental Studies",
		"CHEM" => "Chemistry",
		"ECON" => "Economics",
		"ENGL" => "English",
		"CSCI" => "Computer Science",
		"GEOG" => "Geography",
		"GSCI" => "Geological Sciences",
		"HIST" => "History",
		"H&PE" => "Health & PE",
		"HONR" => "Honors",
		"HUMN" => "Humanities",
		"INTD" => "Interdisciplinary",
		"MATH" => "Math",
		"PHYS" => "Physics",
		"THEA" => "Theater",
		"WRIT" => "Writing",
		"SOCI" => "Sociology",
		"PLSC" => "Political Science",
		"SPAN" => "Spanish",
		"FREN" => "French",
		"JAPN" => "Japan",
		"GERM" => "Germany",
		"LATN" => "Latin",
		"ITAL" => "Italian",
		"RUSS" => "Russian",
		"CHIN" => "Chinese",
		"ARBC" => "Arabic",
		"MGMT" => "Management",
		"MUSC" => "Music",
		"PHIL" => "Philosophy",
		"PSYC" => "Psychology",
		"WMST" => "Women's Studies"}

departments.each_pair do |department, full_department|
	$redis.sadd(RedisHelper.departments, department)
	$redis.set(RedisHelper.department_title(department), full_department)

	doc = Nokogiri::HTML(File.open("data/10-16-11;14:42:06/#{department}.html").read)

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
		elsif(index == 5) 	
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
			if course.time_id == nil
				#puts course.days
				#puts course.time
			end

			course.location = cell.content 

			if previous_course == nil
				course.save_course
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
