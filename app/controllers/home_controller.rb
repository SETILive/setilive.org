class HomeController < ApplicationController
  before_filter CASClient::Frameworks::Rails::GatewayFilter

  def index 
    
    
  end

  def stats
    respond_to do |format|
      format.json do 
        reply = Rails.cache.fetch(:stats, :expires_in => 2.seconds) do 
          {:total_classifications=>RedisConnection.get("total_classifications"),
           :people_online=> RedisConnection.keys("online_*").count,
           :total_users => ZooniverseUser.count,
           :classification_rate => RedisConnection.keys("recent_classification_*").count
           }.to_json
        end
        render :json=>reply
      end
    end
  end


end
