class ZooniverseUser
  include MongoMapper::Document

  key :zooniverse_user_id, Integer
  key :email, String
  key :api_key, String 
  key :name, String 
  key :favourite_ids, Array 
  key :badges, Array
  key :total_classifications , Integer, :default => 0
  key :total_follow_ups , Integer,  :default => 0
  key :total_signals , Integer,  :default => 0
  key :total_logins, Integer, :default =>0
  key :talk_click_count, Integer, :default => 0 
  key :classification_count, Hash
  key :signal_count, Hash
  key :follow_up_count, Hash
  key :last_login, Date 
  key :seen_tutorial, Boolean, :default => false
  key :sweeps_status, String, :in =>['none', 'in','out'], :default=>'none'
  key :seen_subject_ids, Array
  key :agreed_to_sweeps_rules, Boolean, :default => false
  key :agreed_to_email, Boolean, :default => false
  key :came_from_discovery, Boolean, :default=>false
  
  timestamps! 
  
  one :zooniverse_user_extra_info
  has_many :classifications
  has_many :seen_subjects, :in => :seen_subject_ids, :class_name => "Subject"
  has_many :favourites, :in => :favourite_ids, :class_name => "Observation"
  
  after_create :increment_count

  def award_badges 
    Badge.not_awarded(self).each do |badge|
      badge.award_to self if badge.award?(self)
    end
  end
  
  def update_classification_stats(classification)
     updater = update_classification_count(classification)
     updater.deep_merge! update_signal_count(classification)
     updater.deep_merge! update_seen(classification.subject)
     collection.update({ :_id => id }, updater)
     RedisConnection.setex "online_#{self.id}", 10*60, 1
  end
  
  def update_seen(subject)
    { :$addToSet => { 'seen_subject_ids' => subject.id } }
  end 
  
  def update_classification_count(clasificaiton)
     { :$inc => { 'total_classifications' => 1 } }
  end
  
  def update_signal_count(classification)
    updater = { :$inc => { } }
    
    classification.subject.observations.each do |observation|
      updater[:$inc]["signal_count.#{ observation.id }"] = observation.subject_signals.count
    end
    updater
  end

  def badgeDetails
    self.badges.collect{|b| { badge: Badge.find(b['id']), level: b['level'] } }
  end
  
  def recent_observations(opts = { })
    _paginated_recents seen_subject_ids, opts
  end
  
  def recent_favourites(opts = { })
    _paginated_recents favourite_ids, opts
  end
  
  def increment_count
    RedisConnection.incr 'zooniverse_user_count'
  end
  
  private
  
  def _paginated_recents(observation_ids, opts = { })
    opts = { page: 1, per_page: 8 }.merge opts.symbolize_keys
    offset = opts[:per_page] * (opts[:page] - 1)
    json = {
      page: opts[:page],
      pages: (observation_ids.length / opts[:per_page].to_f).ceil,
      per_page: opts[:per_page]
    }
    
    observation_fields = [:image_url, :uploaded, :source_id, :subject_id]
    observation_options = { fields: observation_fields, skip: offset, limit: opts[:per_page], sort: [:$natural, -1] }
    observation_selector = { :subject_id => { :$in => observation_ids } }
    
    results = Observation.collection.find(observation_selector, observation_options).to_a
    source_ids = results.collect{ |result| result['source_id'] }
    subject_ids = results.collect{ |result| result['subject_id'] }
    
    sources = Hash[ *Source.collection.find({ :_id => { :$in => source_ids } }, { fields: [:name] }).to_a.collect(&:values).flatten ]
    subjects = Hash[ *Subject.collection.find({ :_id => { :$in => subject_ids } }, { fields: [:zooniverse_id] }).to_a.collect(&:values).flatten ]
    
    results.each do |result|
      result['source_name'] = sources[result['source_id']]
      result['subject_id'] = subjects[result['subject_id']]
    end
    
    json[:collection] = results
    json
  end
end
