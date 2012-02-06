class Workflow
  include MongoMapper::Document
  key :name, String
  key :version, String 
  key :details, Hash

  many :classifications
end
