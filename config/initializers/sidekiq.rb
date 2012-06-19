redis_config = YAML.load_file('config/redis.yml')
redis_config = redis_config[Rails.env].inject({}){|r,a| r[a[0].to_sym]=a[1]; r}

if Rails.env.development?
  Sidekiq.configure_server do |config|
    config.redis = { :url => "redis://#{redis_config[:host]}:#{redis_config[:port]}/", :namespace => 'setiliveworkers' }
  end

  Sidekiq.configure_client do |config|
    config.redis = {  :url => "redis://#{redis_config[:host]}:#{redis_config[:port]}/", :namespace => 'setiliveworkers' , :size => 1 }
  end

elsif Rails.env.production?
  
  Sidekiq.configure_server do |config|
    config.redis = { :url =>  "redis://#{redis_config['username']}:#{redis_config[:password]}@#{redis_config[:host]}:#{redis_config[:port]}/", :namespace => 'setiliveworkers' }
  end


  Sidekiq.configure_client do |config|
    config.redis = {  :url =>  "redis://#{redis_config['username']}:#{redis_config[:password]}@#{redis_config[:host]}:#{redis_config[:port]}/", :namespace => 'setiliveworkers', :size => 1 }
  end

end