require 'rubygems'
require 'sinatra'
require 'omniauth'
require 'omniauth-facebook'
require 'redis'
require 'digest/sha1'
require 'open-uri'

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

enable :sessions

use Rack::Session::Cookie
use OmniAuth::Builder do
	provider :facebook, '186503511460774', '4078a614ca76dab02c08d06411564a4b'
end

get '/' do
	@session = session

	erb :splash, { :layout => false }
end

get '/courses.json' do
	@data = Everything.new
	erb :courses, { :layout => false }
end

get "/schedules" do
	crns = params[:crns]

	@scheduler = Scheduler.new

	crns.each { |crn| @scheduler.addSection Section.new(crn) }

	@scheduler.schedules

	erb :schedules, :layout => false
end

get "/section.json" do
	crn = params[:crn]
	
	sections = [Section.new(crn)]

	erb :coursejsonlist, { :layout => false, :locals => { :sections => sections } }
end

get "/schedules.json" do
	headers "Content-Type" => "application/json"

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
	email = params[:email].chomp.gsub(' ', '')

	email_regex = /\A[\w+\-.]+@geneseo\.edu\z/i

	if email_regex.match(email) == nil
		erb :email_error, { :layout => false }
	else
		$redis.sadd('emails', email)

		erb :subscribed, { :layout => false }
	end
end

get "/unsubscribe/:email" do
	email = params[:email]

	$redis.srem('emails', email)
end

get '/scheduletester' do
	erb :scheduletester
end

get "/calendar" do
	@data = Everything.new

	@session = session

	haml :calendar, { :layout => false }
end

get "/user/register" do
	haml :register
end

post "/user/new" do
	username = params[:email]
	password = params[:password]
	password2 = params[:password2]

	if(password != password2)
		return "Passwords don't match"
	end

	id = $redis.incr("user:nextID")
	$redis.set("user:#{username}:id", id)
	$redis.set("user:#{id}:username", username);
	$redis.set("user:#{username}:password", Digest::SHA1.hexdigest(password))

	session[:logged_in] = true
	session[:email] = username

	redirect "/dashboard"
end

get "/user/login" do
	@session = session
	haml :login
end

post "/user/authenticate" do
	email = params[:email]
	password = params[:password]

	if($redis.get("user:#{email}:password") == Digest::SHA1.hexdigest(password))
		session[:logged_in] = true
		session[:email] = email

		return "Logged In"
	else
		return "Username/password not found"
	end
end

post "/user/authenticate.json" do
	email = params[:email]
	password = params[:password]

	if($redis.get("user:#{email}:password") == Digest::SHA1.hexdigest(password))
		session[:logged_in] = true
		session[:email] = email

		@success = true
	else
		@success = false
	end

	erb :authenticatejson, { :layout => false }
end

get "/user/logout" do
	session[:logged_in] = false;
	session[:email] = nil

	if params[:redirect] != nil
		redirect "/" + params[:redirect]
	else
		redirect "/user/login"
	end
end

get "/dashboard" do
	@session = session

	haml :dashboard
end

get "/facebook" do
	code = params[:code]
	token_url =  "https://graph.facebook.com/oauth/access_token?client_id=186503511460774&redirect_uri=http://localhost:9393&client_secret=4078a614ca76dab02c08d06411564a4b&code=#{code}"

	open(token_url)
	return params.inspect
end

get '/auth/:name/callback' do
	auth = request.env['omniauth.auth']
end

helpers do
	def course_json_list sections
		erb :coursejsonlist, { :layout => false, :locals => { :sections => sections }}
	end
end
