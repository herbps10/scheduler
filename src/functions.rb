def isDay(str)
	return true if "MTWRF".split("").include?(str)
	return false
end

def parseDaysAndTime(course, elements, startIndex)
	index = startIndex
	days = []
	while isDay(elements[index])
		days.push(elements[index])
		index += 1
	end

	time = elements[index]

	days.each do |day|
		courseTime = CourseTime.new
		courseTime.day = day
		courseTime.setTime(time)

		course.addCourseTime(courseTime)
	end
end


def printMenu
	puts "[1] List All Classes"
	puts "[2] List All Classes by Department"
	puts "[3] List Class Sections"
	puts "[4] Find Class"
	puts "[5] Add class to schedule"
	puts "[6] View Schedule"
	puts "[7] Remove course from schedule"
	puts "[8] Find Conflicts"
end

def inputCourseInfo()
	puts "Enter department, course number, and section number"

	return gets.chomp.split(" ")
end

def allCaps(str)
	return true if str.upcase == str
	return false
end
