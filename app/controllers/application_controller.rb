class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :cor

  def cor
    puts "RUNNING COR"
    headers['Access-Control-Allow-Origin']  = Rails.env.production? ? 'our.app.whitelist' : '*'
    headers["Access-Control-Allow-Methods"] = %w{GET POST PUT DELETE}.join(",")
    headers["Access-Control-Allow-Headers"] = %w{Origin Accept Content-Type X-Requested-With X-CSRF-Token}.join(",")
    head(:ok) if request.request_method == "OPTIONS"
  end


  attr_accessor :current_zooniverse_user
  
  def application_identifier
    "SETILive: en"
  end
  
  def cas_logout
    CASClient::Frameworks::Rails::Filter.logout(self, "http://www.setilive.org")
  end
  
  def zooniverse_user
    session[:cas_user]
  end
  
  def zooniverse_user_id
    session[:cas_extra_attributes]['id']
  end
  
  def zooniverse_user_api_key
    session[:cas_extra_attributes]['api_key']
  end
  
  def current_zooniverse_user
    ZooniverseUser.first(:zooniverse_user_id => zooniverse_user_id) if zooniverse_user
  end
  
  def signed_id 
    respond_with 403 unless currnet_user 
  end

  helper_method :current_user, :zooniverse_user, :zooniverse_user_id, :zooniverse_user_api_key, :current_zooniverse_user
    
  def current_user
    current_zooniverse_user
  end
  
end
