require 'rubygems'
require 'sinatra'
require 'redis'

require "redishelper.rb"

require "./src/course.rb"
require "./src/coursetime.rb"
require "./src/schedule.rb"
require "./src/everything.rb"
require "./src/department.rb"
require "./src/section.rb"
require "./src/scheduler.rb"
require "./src/sectionlist.rb"
require "./src/courselist.rb"
require "./src/coursesections.rb"

$redis = Redis.new

get '/' do
	@data = Everything.new

	erb :index
end

get '/courses.json' do
	@data = Everything.new
	erb :courses, { :layout => false }
end

get "/schedules" do
	crns = params[:crns]

	@scheduler = Scheduler.new

	crns.each { |crn| @scheduler.addSection Section.new(crn) }

	#return @scheduler.inspect.gsub('<', '<br/>')

	@scheduler.schedules

	erb :schedules, :layout => false
end

get "/schedules.json" do
	crns = params[:crns]

	sections = SectionList.new(crns)
	
	puts sections.sections.length

	oldSection = sections[0]
	course = CourseSections.new

	@scheduler = Scheduler.new

	sections.each do |section|
		if(section.sameCourse?(oldSection))
			course.add section
		else
			@scheduler.courses.add course
			course = CourseSections.new
			course.add section
		end

		oldSection = section
	end

	@scheduler.courses.add course

	@scheduler.schedule

	erb :schedulesjson, :layout => false
end

get "/add/section/:crn" do
	crn = params[:crn]

	puts request.cookies[:schedule]
end

get "/add/course/:title" do
	course = params[:title]
end

post "/subscribe" do
	email = params[:email]

	$redis.sadd('emails', email)

	erb :subscribed
end

get "/unsubscribe/:email" do
	email = params[:email]

	$redis.srem('emails', email)
end
