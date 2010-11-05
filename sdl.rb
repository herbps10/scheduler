include Math

require "sdl"

require "src/course.rb"
require "src/courses.rb"
require "src/coursetime.rb"
require "src/functions.rb"
require "src/schedule.rb"
require "src/scheduler.rb"

class SDL::Screen
	def draw_circle_segment(x, y, r, theta, color)
		if(theta != 0)
			step = 0
			while(step <= theta)
				self.draw_aa_line(x, y, x+r*cos(step - PI/2), y+r*sin(step - PI/2), color)
				step += PI/(r*10)
			end
		end

		self.draw_aa_circle(x, y, r, color)

		end
end

def convertRange(oldValue, oldMin, oldMax, newMin, newMax)
	oldRange = oldMax - oldMin
	newRange = newMax - newMin

	newValue = (((oldValue - oldMin) * newRange)/oldRange)+newMin
	
	return newValue
end

#
# Initialize Courses
#
files = Dir.glob("data/5/courses.geneseo.edu/spring/*.txt")

courses = Courses.new
files.each { |file| courses.parseFile(file) }

#
# Initialize SDL
#
SCREEN_X = 1280;
SCREEN_Y = 1024;

SDL.init SDL::INIT_VIDEO
screen = SDL::set_video_mode(SCREEN_X, SCREEN_Y, 24, SDL::SWSURFACE)

SDL::TTF.init()
font = SDL::TTF.open("assets/futura.ttf", 12)

#
# Setup colors
#
BGCOLOR = screen.mapRGB(0, 0, 0);
FONTCOLOR = [255, 255, 255]

# Initialize department colors
DEPARTMENTCOLORS = {
	"CSCI" => screen.mapRGB(255, 0, 0),
	"MATH" => screen.mapRGB(0, 255, 0),
	"BIOL" => screen.mapRGB(0, 0, 255)
}

#
# Initialize visualization parameters
#
OFFSET_X = 50
OFFSET_Y = 50
CLASS_MIN_RADIUS = 10
CLASS_MAX_RADIUS = 40 
CLASS_WIDTH = 100
CLASS_HEIGHT = 100

# Figure out which course has the largest and smallest capacity
smallestCapacity = -1
largestCapacity = -1
courses.each do |course|
	courseCapacity = course.capacity.to_i

	smallestCapacity = courseCapacity if(smallestCapacity == -1)
	largestCapacity = courseCapacity if(largestCapacity == -1)

	smallestCapacity = courseCapacity if(courseCapacity < smallestCapacity)
	largestCapacity = courseCapacity if(courseCapacity > largestCapacity)
end

screen.fill_rect(0, 0, SCREEN_X, SCREEN_Y, BGCOLOR)

counter = 0
x = 0
y = 0
courses.each do |course|
	enrolled = course.enrolled.to_i
	capacity = course.capacity.to_i

	theta = (enrolled * (2*PI)) / capacity

	radius = convertRange(capacity, smallestCapacity, largestCapacity, CLASS_MIN_RADIUS, CLASS_MAX_RADIUS)
	screen.draw_circle_segment(OFFSET_X + x + radius, OFFSET_Y + y + radius, radius, theta, DEPARTMENTCOLORS[course.department])

	font.drawBlendedUTF8(screen, course.department + " " + course.number + " " + course.section, x + OFFSET_X, y + OFFSET_Y + (radius*2), *FONTCOLOR)

	counter += 1
	x += CLASS_WIDTH

	if counter % ((SCREEN_X - OFFSET_X) / CLASS_WIDTH) == 0
		y += CLASS_HEIGHT
		x = 0
	end
end

screen.flip

running = true
while event = SDL::Event2.poll
	case event
		when SDL::Event2::Quit
		running = false
	end
end
