class Source
  include MongoMapper::Document
  include ZooniverseId
  
  zoo_id :prefix => 'T', :sub_id => '0'
  key :name, String 
  key :coords, Array  
  key :description, String
  key :zooniverse_id, String 
  key :seti_id, String
  key :type, String 
  key :meta, Hash

  many :observations 
  many :classifications 


  def planet_hunters_id
    zooniverse_id.gsub("SSL","SPH") if type=="kepler_planet" 
  end

  def planet_count 
    meta['planets'].count if type =="kepler_planet"
  end

  def active 
    RedisConnection.key("current_target*")
  end


end
