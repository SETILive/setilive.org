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
        render :json => reply
      end
    end
  end

  def telescope_status
     @status = RedisConnection.get('current_status') || 'unknown'
     respond_to do |format|
       format.html
       format.json {render :json => @status.to_json}
     end
  end

  def time_to_followup
     @time = RedisConnection.get('time_to_followup') || '0'
     @ttl = RedisConnection.ttl('time_to_followup')
     respond_to do |format|
       format.html
       format.json {render :json=> {time: @time, ttl: @ttl}.to_json}
     end
  end

  def time_to_new_data
     @time = RedisConnection.get("time_to_new_data") || '0'
     @ttl = RedisConnection.ttl("time_to_new_data")

     respond_to do |format|
       format.html
       format.json {render :json => {time: @time, ttl: @ttl}.to_json}
     end
  end

  def retrieve_system_state
     @telescope_status = RedisConnection.get('current_status') || 'unknown'
     @time_to_followup = RedisConnection.get('time_to_followup') || '0'
     @time_to_followup_ttl = RedisConnection.ttl('time_to_followup')
     @time_to_new_data = RedisConnection.get("time_to_new_data") || '0'
     @time_to_new_data_ttl = RedisConnection.ttl("time_to_new_data")

     data = [
        {key: 'telescope_status', value: @telescope_status},
        {key: 'time_to_followup', value: @time_to_followup_ttl},
        {key: 'time_to_new_data', value: @time_to_new_data_ttl}
      ]
     respond_to do |format|
       format.json {render :json => data.to_json}
     end
  end
end
