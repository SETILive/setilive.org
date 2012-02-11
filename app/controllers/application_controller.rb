class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :cor

  def cor
    headers['Access-Control-Allow-Origin']  = Rails.env.production? ? 'our.app.whitelist' : '*'
    headers["Access-Control-Allow-Methods"] = %w{GET POST PUT DELETE}.join(",")
    headers["Access-Control-Allow-Headers"] = %w{Origin Accept Content-Type X-Requested-With X-CSRF-Token}.join(",")
    head(:ok) if request.request_method == "OPTIONS"
  end

  def application_identifier
    "SETILive: en"
  end
  

  def check_login
    unless zooniverse_user 
      redirect_to '/login'
      return false
    end
  end

  def cas_logout
    CASClient::Frameworks::Rails::Filter.logout(self, "http://www.setilive.org")
  end
  
  def signed_id 
    respond_with 403 unless currnet_user 
  end
    

  def zooniverse_user
    session[:cas_user] || session[:zooniverse_user]
  end
  helper_method :zooniverse_user
  
  def zooniverse_user_id
    session[:cas_extra_attributes] ? session[:cas_extra_attributes]['zooniverse_user_id'] : nil
  end
  helper_method :zooniverse_user_id
  
  def zooniverse_user_api_key
    session[:cas_extra_attributes] ? session[:cas_extra_attributes]['api_key'] : nil
  end
  helper_method :zooniverse_user_api_key
  
  def zooniverse_user_email
    session[:cas_extra_attributes] ? session[:cas_extra_attributes]['email'] : nil
  end
  
  def current_user
    return @current_user if @current_user
    return @current_user = current_zooniverse_user if zooniverse_user
    @current_user
  end
  helper_method :current_user
  
  def current_zooniverse_user
    @current_zooniverse_user ||= create_or_update_zooniverse_user if zooniverse_user
    @current_zooniverse_user
  end
  
  def create_or_update_zooniverse_user
    ZooniverseUser.first_or_create( zooniverse_user_id: zooniverse_user_id ).tap do |user|
      user.name = zooniverse_user
      user.email = zooniverse_user_email
      user.api_key = zooniverse_user_api_key
      user.save if user.changed?
    end



    # if zoony_user.updated_at < 1.hour.ago
    #   update_event = {:event => {:kind => 'workflow_activity', :zooniverse_user_id => "#{zooniverse_user_id}", :project => 'Whale FM', :project_id => '12', :count => "#{zoony_user.activity_for_workflow(1)}", :workflow => 'Whale Sound Matching', :created_at => "#{Time.now}"}}
    #   RestClient.post 'https://zooniverse:events@events.zooniverse.org', update_event.to_json, :content_type => :json
    # end
    
    # return zoony_user
  end
end
