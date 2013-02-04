class Workflow
  include MongoMapper::Document
  key :description, String
  key :primary, Boolean
  key :name, String 
  key :project, String
  key :version, String 
  key :questions, Array

  many :subject_signals

  def self.active_workflow 
    Workflow.where(:primary=>true) 
  end

end
