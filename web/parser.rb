require 'rubygems'
require 'redis'
require 'nokogiri'

require 'redishelper.rb'

class Saver
	@@fields = :crn, :department, :courseNumber, :section, :credits, :title, :days, :time, :capacity, :actual, :remaining, :instructor, :location, :time_id
	@@fields.each { |field| attr_accessor field }

	def save_course
		while $redis.zscore(RedisHelper::department(@department), @title.gsub(' ', '-')) != nil
			@title += "*"
		end

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
		"SOCL" => "Sociology",
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

	doc = Nokogiri::HTML(File.open("data/10-23-11;19:38:32/#{department}.html").read)

	course = Saver.new
	valid_row = false
	index = 0

	previous_course = nil

	doc.css('tr').each do |row|
		row.css('td').each_with_index do |cell, index|
			next if cell.content == ''

			if /[0-9]{5}/ =~ cell.content
				valid_row = true
			end

			if(index == 1) 		
				course.crn = cell.content
			elsif(index == 2) 
				course.department = cell.content
			elsif(index == 3)	
				course.courseNumber = cell.content
			elsif(index == 4) 	
				course.section = cell.content
			elsif(index == 6) 	
				course.credits = cell.content
			elsif(index == 7) 	
				course.title = cell.content.chomp.strip
			elsif(index == 8) 	
				course.days = cell.content
			elsif(index == 9) 	
				course.time = cell.content
			elsif(index == 10) 	
				course.capacity = cell.content
			elsif(index == 11) 	
				course.actual = cell.content
			elsif(index == 12) 	
				course.remaining = cell.content	
			elsif(index == 16) 	
				course.instructor = cell.content	
			elsif(index == 19) 	
				if valid_row == true
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
				else
					if previous_course.days != course.days
						previous_course.days += ',' + course.days
						previous_course.time += ',' + course.time
						previous_course.save_section
					end
				end
			end
		end


		index += 1
	end
end
