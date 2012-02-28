class Subject
  include MongoMapper::Document
  include ZooniverseId

  zoo_id :prefix => 'G', :sub_id => '0'
  key :data_url, String 
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
  key :total_score , Float
  key :pol , Integer 
  key :sub_channel, Integer 
  key :observation_id, Integer 
  key :original_redis_key, String

  key :classification_count, Integer, :default => 0 

  timestamps!

  has_many :observations 
  has_many :classifications

  # validates_presence_of  :observation_id
  #after_save :store_in_redis


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
    self.observations.each.processNow
  end

  def self.tutorial_subject
    Subject.where(:activity_id=>'tutorial').first
  end

  def self.random_frank_subject 
    keys = RedisConnection.keys 'subject_*'
    return nil if keys.empty?
    key = keys.sample
    subject  = BSON.deserialize(RedisConnection.get key)
    RedisConnection.del key
    generate_subject_from_frank(subject, key)
  end

  def self.parse_key_details(key)
     data = key.split("_")
     {observation_id: data[1],
      activity_id: data[2],
      pol: data[3].to_i,
      sub_channel: data[4].to_i
     }
  end

  def self.generate_subject_from_frank(subject,key)
    details = parse_key_details(key)

    s=Subject.create( :activity_id => subject["activityId"],
                      :time_range  => subject["endTimeNanos"].to_i-subject["startTimeNanos"].to_i,
                      :freq_range  => subject["bandwidthMhz"].to_f,
                      :location    => {:time=>subject["startTimeNanos"], :freq=>subject["centerFreqMhz"],
                      :pol => details[:pol],
                      :activity_id => details[:activity_id],
                      :sub_channel => details[:sub_channel],
                      :observation_id => details[:observation_id],
                      :original_redis_key => key
                      }
                    ) 
   

    if s 
      subject['beam'].each_with_index do |beam,index|
        
        beam['data'] =  beam['data'].to_a.to_json
        unless beam['data'].empty?
          source = Source.find_by_seti_id beam['target_id']
          source = Source.create_with_seti_id beam['target_id'] unless source 
         
          if source
            s.observations.create( :data    => beam['data'], 
                                                  :source  => source,
                                                  :beam_no => index,
                                                  :width => subject['width'],
                                                  :height => subject['height']
                                                  )
            
          else 
            throw "Could not find Source for observation #{beam['target_id']}"
          end
        end
      end
    end
    GenerateTalk.perform_async s.id
    s
  end


  def redis_key 
    # Subject.redis_key(activity_id,location)
     "subject_#{self.id}"
  end
  
  # def self.redis_key(activity_id,location)
  #   "subject_#{activity_id}_#{location[:time]}_#{location[:freq]}"
  # end
  

  #probably want to fix this at some point(need to find a way of doing random with pattern)
  def self.get_random_new
    list = RedisConnection.keys("subject_new*")
    with_key list[rand(list.count)]
  end

  # #revisit when rules need tweeking
  # def self.get_high_ranked_seen(user)
  #   temp_key = "#{user.redis_key}_unseen"
  #   RedisConnection.sdiffstore("#{user.redis_key}_unseen" , self.redis_cache_name, user.redis_key)
  #   subject_ids = RedisConnection.sort("#{user.redis_key}_unseen", :by => "*_score'", :order => "DESC", :limit =>[0,1])
  #   select = rand([subject_ids.count, 10].min)
  #   subject_id  = subject_ids[select]
  #   Subject.all.each  {|s| puts s.id}
  #   RedisConnection.del("#{user.redis_key}_unseen")
  #   s= Subject.find_by_id(subject_id.split("_").last) unless subject_id.nil?
  #   s
  # end



  def fetch_persisted_data
    begin
      subject=BSON.deserialize( RestClient.get data_url )
    rescue 
      raise "Could not retrive data from s3"
    end
  end
end
