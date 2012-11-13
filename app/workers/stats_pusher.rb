class StatsPusher
  include Sidekiq::Worker 
  
  def perform
    stats = {:total_classifications=>RedisConnection.get("total_classifications"),
             :people_online=> RedisConnection.keys("online_*").count,
             :total_users => RedisConnection.get('zooniverse_user_count'),
             :classification_rate => RedisConnection.keys("recent_classification_*").count
           }
    
    # puts "pusing #{JSON.pretty_generate stats}"
    push_chan_prefix = Rails.env.development? ? ':dmode-' : ''
    Pusher[push_chan_prefix + 'telescope'].trigger('stats_update', stats)
  end
end
