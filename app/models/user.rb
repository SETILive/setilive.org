class ZooniverseUser
  include MongoMapper::Document

  key :zooniverse_user_id, Integer
  key :api_key, String 
  key :name, String 
  key :favourite_ids, Array 
  key :badge_ids , Array
  timestamps! 

  many :classifications 
  many :favourites, :class_name => "Subject", :in => :favourite_ids
  many :badges, :class_name => "Badge", :in => :badge_ids

  
end
