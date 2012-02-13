class Classification
  include MongoMapper::Document
  timestamps! 

  belongs_to :observation
  belongs_to :zooniverse_user
  belongs_to :subject

  
  many :SubjectSignals

  after_create :update_zooniverse_user, :update_source

  def update_zooniverse_user 
    zooniverse_user.update_classification_stats(self)
  end

  def update_source
    
  end
end
