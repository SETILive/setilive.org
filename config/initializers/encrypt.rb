config = YAML.load_file(Rails.root + 'config' + 'encrypt.yml')[Rails.env]
puts config 
CryptoKey = EzCrypto::Key.with_password config['password'], config['salt']