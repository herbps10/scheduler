require 'rubygems'
require 'sinatra'
require 'redis'
require 'coffee-script'

require "redishelper.rb"

require "./src/course.rb"
require "./src/coursetime.rb"
require "./src/schedule.rb"
require "./src/everything.rb"
require "./src/department.rb"
require "./src/section.rb"
require "./src/scheduler.rb"

$redis = Redis.new

get '/' do
	response.set_cookie("schedule", Time.new.to_f.to_s)


	#s1 = Section.new 12606
	#s2 = Section.new 16279

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

	#return @scheduler.inspect.gsub('<', '')

	@scheduler.schedules

	erb :schedules, :layout => false
end

get "/add/section/:crn" do
	crn = params[:crn]

	puts request.cookies[:schedule]
end

get "/add/course/:title" do
	course = params[:title]
end
