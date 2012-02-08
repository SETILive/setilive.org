class Workflow
  include MongoMapper::Document
  key :description, String
  key :primary, Boolean
  key :name, String 
  key :project, String
  key :version, String 
  key :questions, Array

  many :classifications
end
