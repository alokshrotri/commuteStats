class WelcomeController < ApplicationController
  def index
	@app_url = ENV['URL'] || "http://localhost:3000"
  end
end
