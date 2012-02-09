class ZooniverseUserExtraInfo
  include MongoMapper::Document

  key :first_name  , String
  key :second_name , String
  key :address , String
  key :phone_no , String

  belongs_to :zooniverse_user 

  before_save :encrypt

  def encrypt 
    self.attributes.each_pair do |key,val|
      self[key] = CryptoKey.encrypt val
    end
  end
end
