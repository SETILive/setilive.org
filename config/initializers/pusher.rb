require 'pusher'

config = YAML.load_file(Rails.root + 'config' + 'pusher.yml')[Rails.env]

Pusher.app_id = config['app_id']
Pusher.key    = config['key']
Pusher.secret = config['secret']

