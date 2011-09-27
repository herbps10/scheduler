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
#files = Dir.glob("data/5/courses.geneseo.edu/spring/*.txt")
#files = ["data/11/courses.geneseo.edu/spring/Biology.txt", \
#	 "data/11/courses.geneseo.edu/spring/Computer_Science.txt"]
files = ["data/5/courses.geneseo.edu/spring/Biology.txt", \
	"data/8/courses.geneseo.edu/spring/Biology.txt", \
	"data/9/courses.geneseo.edu/spring/Biology.txt", \
	"data/10/courses.geneseo.edu/spring/Biology.txt", \
	"data/11/courses.geneseo.edu/spring/Biology.txt", \
	"data/30/courses.geneseo.edu/spring/Biology.txt"]

courses = Courses.new
#files.each { |file| courses.parseFile(file) }
fileIndex = 0
courses.parseFile(files[fileIndex])

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

#
# Initialize visualization parameters
#
OFFSET_X = 50
OFFSET_Y = 50
CLASS_MIN_RADIUS = 20
CLASS_MAX_RADIUS = 40
BUFFER_X = 50
BUFFER_Y = 50

def redrawScreen(screen, font, courses)
	screen.fill_rect(0, 0, SCREEN_X, SCREEN_Y, BGCOLOR)

	counter = 1
	x = 0
	y = 0
	largestY = 0
	courses.each do |course|
		enrolled = course.enrolled.to_i
		capacity = course.capacity.to_i

		theta = (enrolled * (2*PI)) / capacity

		radius = convertRange(capacity, courses.smallestCapacity(), courses.largestCapacity(), CLASS_MIN_RADIUS, CLASS_MAX_RADIUS)

		screen.draw_circle_segment(OFFSET_X + x + radius, OFFSET_Y + y + radius, radius, theta, screen.mapRGB(255, 255, 255))

		font.drawBlendedUTF8(screen, course.department + " " + course.number + " " + course.section, x + OFFSET_X, y + OFFSET_Y + (radius*2), *FONTCOLOR)

		x += (radius * 2) + BUFFER_X

		largestY = (radius * 2) + BUFFER_Y if((radius * 2) + BUFFER_Y > largestY)

		if x >= (SCREEN_X - (OFFSET_X * 2))
			y += largestY
			largestY = 0
			x = 0
		end

		counter += 1
	end

	screen.flip
end

redrawScreen(screen, font, courses)

running = true
while running == true
	while event = SDL::Event2.poll
		case event
			when SDL::Event2::Quit
				running = false
				break
			when SDL::Event2::KeyDown
				case event.sym
					when SDL::Key::RIGHT
						if(fileIndex + 1 < files.length)
							fileIndex += 1
							courses = Courses.new
							courses.parseFile(files[fileIndex])
							redrawScreen(screen, font, courses)
						end
						break
					when SDL::Key::LEFT
						if(fileIndex - 1 > 0)
							fileIndex -= 1
							courses = Courses.new
							courses.parseFile(files[fileIndex])
							redrawScreen(screen, font, courses)
						end
						break
				end
				break
		end
	end
end
