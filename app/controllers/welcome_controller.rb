class WelcomeController < ApplicationController
  def index
	@app_url = ENV['app_url']
	logger.debug("This should appear in log")
	logger.debug("APP URL shoudl be printed here: '#{@app_url}'")
  end
end
