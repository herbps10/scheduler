require 'rubygems'
require 'sinatra'
require 'redis'

require "redishelper.rb"

$redis = Redis.new

class Section
	attr_accessor :crn, :title, :instructor, :section

	def initialize(crn)
		data = $redis.hgetall(RedisHelper::section(crn))

		@crn = crn
		@title = data["title"]
		@instructor = data["instructor"]
		@section = data["section"]
	end
end

class Course
	attr_accessor :title, :sections
	
	def initialize(title)
		@sections = []

		data = $redis.hgetall(RedisHelper::course(title))

		puts data.inspect

		@title = data["title"]

		$redis.smembers(RedisHelper::course_sections(@title)).each do |crn|
			@sections.push Section.new(crn)
		end
	end
end

class Department
	attr_accessor :courses

	def initialize(department)
		@department = department
		@courses = []

		$redis.smembers(RedisHelper::department(@department)).each do |title|
			@courses.push Course.new(title)
		end
	end

	def each
		@courses.each do |course|
			yield course
		end
	end
end

get '/' do
	@department = Department.new("PHYS")

	erb :index
end

get '/script.js' do
	coffee :script
end
