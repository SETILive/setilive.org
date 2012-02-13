source 'http://rubygems.org'

gem 'rails', '3.1.1'

# Bundle edge Rails instead:
# gem 'rails',     :git => 'git://github.com/rails/rails.git'

gem 'sqlite3'


# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.1.4'
  gem 'coffee-rails', '~> 3.1.1'
  gem 'uglifier', '>= 1.0.3'
  gem 'eco' 
  gem 'spine-rails'
end

gem 'mongo_mapper'
gem 'bson'
gem 'bson_ext'
gem 'state_machine'
gem 'redis'

gem 'pusher'
gem 'ezcrypto'

gem 'sidekiq'

gem 'pry', group: 'development'

gem "bcrypt-ruby", :require => "bcrypt"

gem "therubyracer"

gem "aws-sdk", "~> 1.3.3"


gem 'libxml-ruby', '2.2.2'
gem 'httparty', '0.8.1'
gem 'multi_xml', '0.4.1' # dependency of HTTParty, but also used directly
gem 'rubycas-client', git: 'git://github.com/parrish/rubycas-client.git', ref: '6dddf665ac3c0e1'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'

group :test do
  # Pretty printed test output
  gem 'turn', :require => false 
  gem 'shoulda'
  gem 'factory_girl_rails'
  gem 'minitest'
  gem 'autotest-rails'
end
