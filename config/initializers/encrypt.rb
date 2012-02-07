config = YAML.load_file(Rails.root + 'config' + 'encrypt.yml')[Rails.env]
CryptoKey = EzCrypto::Key.with_password config['password'], config['salt']