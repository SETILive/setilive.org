class AboutController < ApplicationController
  before_filter CASClient::Frameworks::Rails::GatewayFilter

	def index
		# render layout: false
	end

  def video_tutorial

  end
end
