class Classification
  include MongoMapper::Document
  timestamps! 

  belongs_to :zooniverse_user
  belongs_to :subject

  
  many :SubjectSignals

  after_create :update_zooniverse_user, :update_source, :update_redis, :push_global_stats

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
    StatsPusher.perform_async
  end
end
