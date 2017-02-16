class WelcomeController < ApplicationController
  def index
	@redirecthere = "http://localhost:3000/mystats/show"
  end
end
