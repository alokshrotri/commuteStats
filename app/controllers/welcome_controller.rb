class WelcomeController < ApplicationController
  def index
	@app_url = ENV['URL']
  end
end
