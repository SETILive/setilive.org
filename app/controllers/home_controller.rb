class HomeController < ApplicationController
  before_filter CASClient::Frameworks::Rails::GatewayFilter, :only =>[:index]

  def index 
    
    
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
     @status = RedisConnection.get('current_status')
     respond_to do |format|
       format.html
       format.json{ render :json=> {status: @status}.to_json}
     end
  end
end
