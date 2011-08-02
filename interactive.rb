require "src/course.rb"
require "src/courses.rb"
require "src/coursetime.rb"
require "src/functions.rb"
require "src/schedule.rb"
require "src/scheduler.rb"

files = Dir.glob("add_drop_data/28/*.txt")

courses = Courses.new
files.each { |file| courses.parseFile(file) }

schedule = Schedule.new

input = ""
while input != "q"
	system("clear")
	printMenu
	input = gets.chomp.downcase
	
	if input == "1" # List All Classes
		courses.each do |course|
			course.display
			puts
		end
	elsif input == "2" # List all Classes by Department
		puts "Enter department"
		department = gets.chomp.upcase
		courses.coursesByDepartment(department).each do |course|
			course.display
			puts
		end
	elsif input == "3" # List all class sections
		puts "Enter Department and Class Number, e.g. BIOL 119"
		
		raw = gets.chomp.split(" ")

		department = raw[0]
		number = raw[1]

		courses.coursesByDepartmentAndNumber(department, number).each do |course|
			course.display
			puts
		end
	elsif input == "4" # Find class
		courseInfo = inputCourseInfo()

		courses.getCourse(courseInfo[0], courseInfo[1], courseInfo[2]).display
		puts
	elsif input == "5" # Add class to schedule
		courseInfo = inputCourseInfo()

		course = courses.getCourse(courseInfo[0], courseInfo[1], courseInfo[2])
		
		if course
			if schedule.addCourse(course)
				puts "Class added to schedule"
			else
				puts "This class conflicts with one of your other classes. Do you want to override and add to your schedule anyway? [y/n]"
				answer = gets.chomp.downcase

				if answer == "y"
					schedule.addCourseWithOverride(course, true)
				end
			end

		else
			puts "Class not found"
		end
	elsif input == "6" # Display schedule
		schedule.display
	elsif input == "7" # Remove class from schedule
		courseInfo = inputCourseInfo()

		if schedule.removeCourse(courseInfo[0], courseInfo[1], courseInfo[2])
			puts "Class removed"
		else
			puts "Could not remove class"
		end
	elsif input == "8" # Check schedule for conflicts
		conflicts = schedule.checkForConflicts
		
		if conflicts != []
			if conflicts.length == 1
				puts "There was one scheduling conflict found"
			else
				puts "There were " + conflicts.length.to_s + " scheduling conflicts found"
			end

			conflicts.each do |conflictPair|
				puts "Conflict:"
				conflictPair[0].shortDisplay
				conflictPair[1].shortDisplay
				puts
			end
		end
	end

	puts "Press any key to continue"
	gets
end
