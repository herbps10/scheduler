require 'rubygems'
require 'twilio-ruby'
require 'redis'

require 'redishelper.rb'

$redis = Redis.new

account_sid = 'ACdbe92b6dfc291e35ecaaf3d9de4c1d19'
auth_token  = '3265dd18a6b5332ebecd38844668838c'

@client = Twilio::REST::Client.new account_sid, auth_token


$redis.smembers('users').each do |user|
	subscriptions = $redis.smembers("user:#{user}:subscriptions").each do |crn|
		subscription = $redis.hgetall("user:#{user}:subscription:#{crn}")
		puts subscription
		
		course = $redis.hgetall(RedisHelper::section(crn))

		if subscription["full"].to_i == 1 and (course["actual"].to_i < course["capacity"].to_i)
			to = $redis.get("user:#{user}:phone")
			if(to != nil)
				to = "+1" + to if(to.length == 10) 

				$redis.hset("user:#{user}:subscription:#{crn}", "full", 0)

				puts "Sending SMS to " + to

				@client.account.sms.messages.create(
					:from => "+14155992671",
					:to => to,
					:body => course["department"] + " " + course["courseNumber"] + " is now open!"
				)
			end
		end

		if course["actual"].to_i >= course["capacity"].to_i
			$redis.hset("user:#{user}:subscription:#{crn}", "full", 1)
		end
	end
end
