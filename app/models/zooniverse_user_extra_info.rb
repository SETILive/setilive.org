class ZooniverseUserExtraInfo
  include MongoMapper::Document

  key :first_name  , String
  key :last_name , String
  key :address1 , String
  key :address2 , String
  key :city , String
  key :state , String
  key :zip_code, String

  key :phone_no , String

  belongs_to :zooniverse_user 

  before_save :encrypt

  def encrypt 
    self.attributes.each_pair do |key,val|
      self[key] =  Base64.encode64(CryptoKey.encrypt val)
    end
  end
end
