redis_config = YAML.load_file('config/redis.yml')
redis_config = redis_config[Rails.env].inject({}){|r,a| r[a[0].to_sym]=a[1]; r}
if Rails.env.development?
  Sidekiq::Client.redis = Sidekiq::RedisConnection.create(:url => "redis://#{redis_config[:host]}:#{redis_config[:port]}/")
elsif Rails.env.production?
  Sidekiq::Client.redis = Sidekiq::RedisConnection.create(:url => "redis://#{redis_config['username']}:#{redis_config[:password]}@#{redis_config[:host]}:#{redis_config[:port]}/")
  
end