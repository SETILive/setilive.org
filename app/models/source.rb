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

  def self.create_with_seti_id(seti_id)
    puts "Creating from the redis definition #{seti_id}"
    s = Source.new(name: seti_id, seti_id: seti_id)

    if RedisConnection.keys("target_#{seti_id}").count > 0
      details = JSON.parse(RedisConnection.get "target_#{seti_id}")
      if details["target_name"].match(/KOI/)
        type = 'kepler_planet'
      else
        type = 'other'
      end
      s.name = details["target_name"].split(" ")[0].strip
      s.ra = details["ra"]
      s.dec = details["dec"]
    end 
    s.save
  end


end
