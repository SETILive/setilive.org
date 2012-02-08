
class Classification
  include MongoMapper::Document
  

  timestamps! 

  belongs_to :observation
  belongs_to :user 
  belongs_to :subject
  many :SubjectSignals

  after_create :update_zooniverse_user, :update_source

  def update_zooniverse_user 
    current_zooniverse_user.update_classificaiton_stats(self)
  end

  def update_source
    
  end

end
