class Observation
  include MongoMapper::Document

  
  belongs_to :source 

end
