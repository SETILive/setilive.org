class Subject
  include MongoMapper::Document

  key :data_url, String 
  key :beam , Array
  key :activity_id, String, :requited=>true
  key :location, Hash
  key :time_range, Float
  key :freq_range, Float 
  key :start_time, Time 
  key :end_time  , Time 
  key :bandwidth_range, Float
  key :central_freq , Float
  key :status, String, :default =>"inactive"
  key :scores, Hash
  key :width , Integer
  key :height , Integer
  key :uploaded, Boolean, :default =>"false"
  key :total_score , Float

  timestamps!

  belongs_to :observation
  has_many :classifications

  # validates_presence_of  :observation_id
  #after_save :store_in_redis
  after_save :persist_on_s3


  scope :paused,             where(:status=>'paused')
  scope :active,             where(:status=>'active')
  scope :done,               where(:status=>'done')

  state_machine :status, :initial=> 'active' do 
    after_transition :on => :pause,        :do => :remove_from_redis
    after_transition :on => :activate,     :do => :store_in_redis 
    after_transition :on => :mark_as_done, :do => :remove_form_redis 
      
    event :pause do
      transition :to => 'paused', :from =>'active'
    end
    
    event :activate do
      transition :to => 'active', :from =>['paused','done']
    end
    
    event :done do
      transition :to => 'done', :from =>['paused','active']
    end
  end

  def data=(data)
    @data=data
  end
  
  def activate
    status = "active"
    store_in_redis
  end

  def deactivate
    status = "inactive"
    remove_from_redis
  end

  def data
    @data ||= fetch_persisted_data
  end

  def persist_on_s3
    SubjectUploader.perfom_async(self)
  end

  def remove_from_redis 
    RedisConnection.srem Subject.redis_cache_name, self.redis_key 
    RedisConnection.del "#{self.redis_key}_score"
  end

  def self.redis_cache_name 
    'active_seen_subjects'
  end

  def calculate_subject_score
    score=0
    scores.each_pair do |workflow_id, workflow_score|
      score += workflow_score * Workflow.find(workflow_id).weight
    end
    total_score=score
  end

  def update_score_for_workflow!(workflow,score)
    scores[workflow.id.to_s] ||= 0  
    scores[workflow.id.to_s] += score 
    calculate_subject_score 
    self.save
  end

  def self.with_key(key)
    data = RedisConnection.get key
    if data
      subject  = BSON.deserialize(data) 
      s        = generate_subject_from_frank subject
    end
    s
  end

  def self.random_frank_subject 
    keys = RedisConnection.keys 'subject_*'
    return nil if keys.empty?
    subject  = BSON.deserialize(RedisConnection.get keys.sample)
    generate_subject_from_frank(subject)

  end

  def self.generate_subject_from_frank(subject)
    puts "subject width height "
    puts subject['width'] , subject['height']
    s=Subject.new(    :activity_id => subject["activityId"],
                      :time_range  => subject["endTimeNanos"].to_i-subject["startTimeNanos"].to_i,
                      :freq_range  => subject["bandwidthMhz"].to_f,
                      :location    => {:time=>subject["startTimeNanos"], :freq=>subject["centerFreqMhz"]},
                      :width => subject['width'],
                      :height=> subject['height'])
    
    subject['beam'].each do |beam|
      beam['data'] = beam['data'].to_a
      s.beam << beam unless beam['data'].empty?
    end
    s
  end

  def self.with_pattern(pattern)
    RedisConnection.keys(pattern).collect {|key| with_key(key) }
  end

  def redis_key 
    # Subject.redis_key(activity_id,location)
     "subject_#{self.id}"
  end
  
  # def self.redis_key(activity_id,location)
  #   "subject_#{activity_id}_#{location[:time]}_#{location[:freq]}"
  # end
  
  def upload_data_packet_to_s3(data)
    self.data_url = "#{SiteConfig.s3_subject_bucket}/subject_#{self.id}.bson" if S3Upload.upload_asset("subject_#{self.id}.bson", data)
  end
  
  def get_data
    BSON.deserialize(RestClient.get(data_url))
  end

  def self.next_unseen_for_user_on_interface(user, interface)
    subject = ( get_new ? get_random_new : get_high_ranked_seen )

  end

  #probably want to fix this at some point(need to find a way of doing random with pattern)
  def self.get_random_new
    list = RedisConnection.keys("subject_new*")
    with_key list[rand(list.count)]
  end

  #revisit when rules need tweeking
  def self.get_high_ranked_seen(user)
    temp_key = "#{user.redis_key}_unseen"
    RedisConnection.sdiffstore("#{user.redis_key}_unseen" , self.redis_cache_name, user.redis_key)
    subject_ids = RedisConnection.sort("#{user.redis_key}_unseen", :by => "*_score'", :order => "DESC", :limit =>[0,1])
    select = rand([subject_ids.count, 10].min)
    subject_id  = subject_ids[select]
    Subject.all.each  {|s| puts s.id}
    RedisConnection.del("#{user.redis_key}_unseen")
    s= Subject.find_by_id(subject_id.split("_").last) unless subject_id.nil?
    s
  end

  def self.active_subjects 
    return Subject.where(:status=>"active").all | with_pattern("subject_new_*")
  end
  
  def upload_data 
    begin
      S3Uploader.upload_asset "#{self.redis_key}.bson}", BSON.serialize(self.attributes)
    rescue 
      raise "Could not upload subject to s3"
    end
  end

  def fetch_persisted_data
    begin
      subject=BSON.deserialize( RestClient.get data_url )
    rescue 
      raise "Could not retrive data from s3"
    end
  end
end
