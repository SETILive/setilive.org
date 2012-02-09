class AboutController < ApplicationController
  before_filter CASClient::Frameworks::Rails::GatewayFilter

	def index
		# render layout: false
	end
end
