class Courses
	def initialize
		@courses = []

		# These are used as cache variables by smallestCapacity() and largestCapacity()
		@largestCapacity = -1
		@smallestCapacity = -1
	end

	def addCourse(course)
		@courses.push course
	end

	# Reads in all the courses from a course listing file
	def parseFile(filename)
		file = File.new(filename, "r")

		lines = file.readlines

		currentCourse = nil
		lines[6..lines.length].each do |line| # We can safely ignore the first 6 lines of the file as they contain no course information
			next if line.strip == ""
			
			elements = line.split(" ")

			# This line will have section information.
			if elements[0] == "1" or elements[0] == "7" # These lines always start with a 1 or a 7 for some reason
				# If there is more than one section defined here, add the previous section and then start a new course for the next section
				if currentCourse.section != nil and currentCourse.section != elements[2]
					addCourse(currentCourse) if currentCourse.section != nil

					tempDepartment = currentCourse.department
					tempNumber = currentCourse.number

					currentCourse = Course.new
					currentCourse.department = tempDepartment
					currentCourse.number = tempNumber
				end

				currentCourse.section = elements[2]
				currentCourse.credits = elements[3] # This is somewhat broken, a lot of the classes are defined as having .0 credits in the file for some reason

				# Split open the #/# section into how many people are enrolled out of how big the class is
				enrollmentComponents = elements[4].split("/");
				currentCourse.enrolled = enrollmentComponents[0]
				currentCourse.capacity = enrollmentComponents[1]

				# Parse out the instructor(s)
				index = elements.length - 1
				instructor = ""
				while(allCaps(elements[index]) != true and elements[index].upcase.match("[0-9]+") == nil)
					instructor += elements[index].sub(",", "") + " "
					index -= 1
				end
				instructor.strip!

				currentCourse.instructor = instructor

				parseDaysAndTime(currentCourse, elements, 5)

			# we're on a line that says what time the class meets on a certain day. see bio.txt for an example of this
			elsif isDay(elements[0])
				parseDaysAndTime(currentCourse, elements, 0)

			# Otherwise, we're on the first line of a course declaration. This line has the course number and title.
			else
				if currentCourse != nil and currentCourse.section != nil
					addCourse(currentCourse)
				end

				currentCourse = Course.new
				currentCourse.department = elements[0]
				currentCourse.number = elements[1]
			end
		end
	end

	def getCourse(department, number, section)
		@courses.each do |course|
			return course if course.department == department and course.number == number and course.section == section
		end

		return false
	end

	def coursesByDepartment(department)
		courses = []
		@courses.each do |course|
			courses.push(course) if course.department == department
		end

		return courses
	end

	def coursesByDepartmentAndNumber(department, number)
		courses = []
		@courses.each do |course|
			courses.push(course) if course.department == department and course.number == number
		end

		return courses
	end

	def each
		@courses.each do |course|
			yield course
		end
	end

	def length
		return @courses.length
	end

	def smallestCapacity()
		# The smallest course capacity has been cached in an instance variable.
		return @smallestCapacity if(@smallestCapacity != -1)

		smallestCapacity = -1
		@courses.each do |course|
			courseCapacity = course.capacity.to_i
			smallestCapacity = courseCapacity if(smallestCapacity == -1 or courseCapacity < smallestCapacity)
		end

		@smallestCapacity = smallestCapacity
		return smallestCapacity
	end

	def largestCapacity()
		# The largest course capacity has been cached in an instance variable.
		return @largestCapacity if (@largestCapacity != -1)

		largestCapacity = -1
		@courses.each do |course|
			courseCapacity = course.capacity.to_i
			largestCapacity = courseCapacity if(largestCapacity == -1 or courseCapacity > largestCapacity)
		end

		@largestCapacity = largestCapacity
		return largestCapacity
	end

	def categorizeByTime
		courseBuckets = []

		each do |course|
		end
	end
end
