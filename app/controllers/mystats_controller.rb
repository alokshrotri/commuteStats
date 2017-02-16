class MystatsController < ApplicationController
	def show
	  
			@errors = params["error"]
			
			if !params.has_key?("code") || params["code"].blank?
				raise("Authorization failed(#{@errors})")
			end
			
			@code = params["code"]
			
			access_token,athlete_id = authenticate(@code)
			
			@all_commute_distance,@all_commute_count,@id = all_commute_stats(access_token,athlete_id)
			@first_act = my_act(access_token,@id)
			
		
	end

	# private
	
	def my_act(access_token,act_id)
		require 'strava/api/v3'
			
		# logger.debug("Authenticating with access token '#{access_token}' for athlete '#{athlete_id}'")
		client = Strava::Api::V3::Client.new(:access_token => access_token)
		
		return client.retrieve_an_activity(act_id)
	end
	
	def authenticate(code)
		require 'net/http'
		require 'uri'
		
		client_id = ENV['client_id']
		client_secret = ENV['secret_key']
		
		post_data = {"client_id"=>client_id, "client_secret"=>client_secret, "code"=>code}
		uri = URI.parse("https://www.strava.com/oauth/token")
		
		http = Net::HTTP.new(uri.host, uri.port)
		http.use_ssl = true
		request = Net::HTTP::Post.new(uri.request_uri)
		request.set_form_data(post_data)
		response = http.request(request)
		
		if !response.code === 200
			raise("Error during OAuth. Code: #{response.code} - '#{response.body}'")
		end
		
		resObj = JSON.parse(response.body)
		access_token = resObj["access_token"]
		athlete_id = resObj["athlete"]["id"]
		@firstname = resObj["athlete"]["firstname"]
		
		return access_token,athlete_id
	end
	
	def all_commute_stats(access_token,athlete_id)
		
		total_distance = 0
		total_count = 0
		more_records = true
		page = 1
		while more_records
				more_records,distance,count,id = list_activities(access_token,athlete_id,page)
				total_distance = total_distance + distance.to_f
				total_count = total_count + count.to_f
				page = page + 1
		end
		
		return total_distance,total_count,id
	end
	
	def list_activities(access_token,athlete_id,page)
		require 'strava/api/v3'
			
		logger.debug("Authenticating with access token '#{access_token}' for athlete '#{athlete_id}'")
		client = Strava::Api::V3::Client.new(:access_token => access_token)
		options = {}
		options[:page] = page
		options[:per_page] = "100"
		list_of_activities = client.list_athlete_activities(options)
		query_ahead = false
		if list_of_activities.length > 0
			distance = 0
			count = 0
			query_ahead = true
			start_of_year = "2017-01-01T00:00:00Z"
			for act in list_of_activities do
				if act["start_date_local"] < start_of_year
					query_ahead = false
					break
				end
				if act["commute"] === true
					distance = distance + act["distance"]
					count = count + 1	
					id = act["id"]
				end
			end
		end			
		return query_ahead,distance,count,id
	end
end