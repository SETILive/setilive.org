class SubjectSignal
  include MongoMapper::Document
  
  key :characteristics , Array
  key :start_coords , Array
  key :end_coords , Array
  key :gradient , Float
  
  belongs_to :classification
  belongs_to :observation
  belongs_to :workflow
end
