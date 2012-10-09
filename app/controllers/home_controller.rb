class HomeController < ApplicationController
  before_filter CASClient::Frameworks::Rails::GatewayFilter, :only =>[:index, :team]
  
  def index 
  end
  
  def team
    
  end

  def ted

  end

  def stats
    respond_to do |format|
      format.json do 
        reply = { total_classifications: RedisConnection.get("total_classifications"),
                  people_online: RedisConnection.keys("online_*").count,
                  total_users: ZooniverseUser.count,
                  classification_rate: RedisConnection.keys("recent_classification_*").count }
        render :json=>reply
      end
    end
  end

  def telescope_status
     @status = RedisConnection.get('current_status') || 'unknown'
     respond_to do |format|
       format.html
       format.json{ render :json=> {status: @status}.to_json}
     end
  end

  def time_to_followup
     @time = RedisConnection.get('time_to_followup') || '0'
     respond_to do |format|
       format.html
       format.json{ render :json=> {time: @time}.to_json}
     end
  end

  def time_to_new_data
     @time = RedisConnection.get('time_to_new_data') || '0'
     respond_to do |format|
       format.html
       format.json{ render :json=> {status: @time}.to_json}
     end
  end
end
