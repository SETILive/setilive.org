class Source
  include MongoMapper::Document
  key :name, String 
  key :coords, Array  
  key :description, String
  key :zooniverse_id, String 
  key :type, String 
  key :meta, Hash

  many :observations 

  def most_recent_observation
    observations.order([:created_at,-1]).limit(1).first
  end

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
