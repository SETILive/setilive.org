class Classification
  include MongoMapper::Document
  timestamps!
  
  belongs_to :zooniverse_user
  belongs_to :subject
  has_many :subject_signals
  
  after_create :update_zooniverse_user, :update_redis, :push_global_stats
  
  def self.recent
    recents = RedisConnection.get 'recent_classifications'
    return JSON.load(recents) if recents
    
    fields = [:zooniverse_user_id, :subject_id]
    opts = { limit: 4, sort: ['created_at', -1], fields: fields }
    
    results = Classification.collection.find({ }, opts).to_a
    
    results.each do |result|
      user_id = result.delete 'zooniverse_user_id'
      subject_id = result.delete 'subject_id'
      
      observation = Observation.collection.find_one({ uploaded: true, subject_id: subject_id }, { fields: [:image_url, :source_id ] })
      result['observation_id'] = observation['_id']
      result['user_name'] = ZooniverseUser.collection.find_one({ _id: user_id }, { fields: [:name] }).try :[], 'name'
      result['image_url'] = observation['image_url']
      result['source_name'] = Source.collection.find_one({ _id: observation['source_id'] }, { fields: [:name] }).try :[], 'name'
    end
    
    RedisConnection.setex 'recent_classifications', 60, JSON.dump(results)
    results.as_json
  end
  
  def update_zooniverse_user 
    zooniverse_user.update_classification_stats(self)
  end
  
  def update_redis 
    RedisConnection.setex "recent_classification_#{self.id}", 60, 1
    RedisConnection.incr "total_classifications"
  end
  
  def push_global_stats
    StatsPusher.perform_async if (RedisConnection.get("total_classifications").to_i % 500) ==0
  end
  
  # def push_classification
  #   ClassificationPusher.perform_async({ classification_id: self.id, subject_id: self.subject_id, observation_locations: observation_locations })
  # end
end
