class Source
  include MongoMapper::Document
  include ZooniverseId
  
  zoo_id :prefix => 'T', :sub_id => '0'
  
  key :name, String 
  key :coords, Array  
  key :description, String
  key :zooniverse_id, String 
  key :seti_ids, Array
  key :type, String 
  key :meta, Hash

  many :observations 
  many :classifications 

  BOOTSTRAP ||= false

  after_create{ Source.cache_sources unless BOOTSTRAP }

  def self.find_by_seti_id(seti_id)
    Source.where(:seti_ids => seti_id).first
  end

  def planet_hunters_id
    zooniverse_id.gsub("SSL","SPH") if type=="kepler_planet" 
  end

  def planet_count 
    meta['planets'].count if type =="kepler_planet"
  end

  def active 
    RedisConnection.keys("current_target*")
  end

  def as_geo_json
    result = {type: "Feature"}
    result[:geometry] = {coordinates: self.coords , type: 'Point'}
    result[:properties]= self.as_json
    result  
  end

  def to_geo_json
    result.to_json
  end


  def self.create_with_seti_id(seti_id)
    # puts "Creating from the redis definition #{seti_id}"
    s = Source.new(name: seti_id.to_s, seti_ids: [seti_id.to_s], type: "other")
    if RedisConnection.exists("target_#{seti_id}")
      details = JSON.parse(RedisConnection.get "target_#{seti_id}")
      if details["target_name"].match(/KOI/)
        s.type = 'kepler_planet'
      else
        s.type = 'other'
      end
      s.name = details["target_name"].split(" ")[0].strip
      s.coords[0] = details["ra"]
      s.coords[1] = details["dec"]
    end
    s.save
    s
  end

  def self.get_cached_sources
    Rails.cache.fetch(:cached_sources, :expires_in => 1.hour) { Source.cache_sources }
  end

  def self.cache_sources
    # puts "caching sources "
    sources = Source.all.to_json
    RedisConnection.set "cached_sources", sources
    # puts "cached sources "
    sources
  end
end
