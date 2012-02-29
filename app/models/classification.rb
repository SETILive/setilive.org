class Classification
  include MongoMapper::Document
  timestamps! 

  belongs_to :zooniverse_user
  belongs_to :subject

  
  has_many :subject_signals

  after_create :update_zooniverse_user, :update_source, :update_redis, :push_global_stats, :push_classification

  def update_zooniverse_user 
    zooniverse_user.update_classification_stats(self)
  end

  def update_source
    
  end

  def update_redis 
    RedisConnection.setex "recent_classification_#{self.id}", 10*60, 1
    RedisConnection.incr "total_classifications"  
  end

  def push_global_stats
    StatsPusher.new.perform
  end

  def push_classification
    # ClassificationPusher.perform_async {classificaton_id: self.id, subject_id: self.subject_id, observation_locations: observation_locations}
  end


  def recent_classificaitons
    return 
  end
end
