require 'rubygems'
require 'redis'
require 'nokogiri'

require 'redishelper.rb'

class Saver
	@@fields = :crn, :department, :courseNumber, :section, :credits, :title, :days, :time, :capacity, :actual, :remaining, :instructor, :location, :time_id, :description
	@@fields.each { |field| attr_accessor field }

	def save_course
		while $redis.zscore(RedisHelper::department(@department), @title.gsub(' ', '-')) != nil
			@title += "*"
		end

		$redis.hset(RedisHelper::course(@title), 'title', @title)
		$redis.hset(RedisHelper::course(@title), 'credits', @credits)
		$redis.hset(RedisHelper::course(@title), 'courseNumber', @courseNumber)
		$redis.hset(RedisHelper::course(@title), 'description', @description)
		$redis.hset(RedisHelper::course(@title), 'department', @department)

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
		$redis.hset(RedisHelper::course(@title), 'description', @description)
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

	
	###
	### Parse out the descriptions from the details file
	###

	descriptions = {}

	details = Nokogiri::HTML(File.open("data/03-08-12;22:40:27/#{department}-details.html").read)

	details.css('.nttitle').each_with_index do |title, title_index|
		course_title =  title.content

		course_number = course_title[5..7]

		#department = title.to_s.match(/([A-Z]+)/)[0]
		#course_number = title.to_s.match(/crse_numb_in=([0-9A-Z]+)/)[1]

		description = title.parent().next()
		if(description.to_s.split('<br>').length > 0)
			content = description.to_s.split('<br>').at(0).gsub('<td class="ntdefault">', '').gsub('<tr>', '').gsub("\n", '')
			
			descriptions[course_number] = content
		end
	end

	###
	### Parse the main listings
	### 

	doc = Nokogiri::HTML(File.open("data/03-08-12;22:40:27/#{department}.html").read)

	course = Saver.new
	valid_row = false
	course_index = 0

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
				course.description = descriptions[course.courseNumber.to_s]
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

		course_index += 1

	end
end

departments.each_pair do |department, full_department|
	

end
