class Simulation
  include MongoMapper::Document
  include Randomizer
  
  randomize_with :random_number
  
  key :yrefpix, Integer
  key :xref,  Float
  key :power, Float
  key :sigmaj,  Float
  key :yref,  Float
  key :sigmaf, Float
  key :sigmaa, Float
  key :ydelt, Float
  key :accel, Float
  key :xrefpix, Float
  key :width, Integer
  key :tint, Float
  key :fstart, Float
  key :height, Integer
  key :xdelt, Float
  key :simversion, String
  key :erratic, Float 
  key :truncated, String

  key :random_number, Float

  key :active, Boolean, :default => false 

  key :data_url, String
  key :image_url, String

  many :observations 

  scope :active, where(:active=>true)
  scope :inactive, where(:active=>false)

  timestamps! 

  def data 
    JSON.parse(HTTParty.get(data_url))
  end
end
