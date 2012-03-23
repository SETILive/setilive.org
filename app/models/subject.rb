class Subject
  include MongoMapper::Document
  include ZooniverseId
  include Randomizer
  
  randomize_with :random_number
  key :random_number, Float

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

  key :has_simulation, Boolean, :default=>false

  key :classification_count, Integer, :default => 0 

  scope :simulation , where(:has_simulation=>true)
  scope :real , where(:has_simulation=>false)

  timestamps!

  has_many :observations 
  has_many :classifications

  after_create :pop_in_redis_temp

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

  def pop_in_redis_temp
    RedisConnection.setex("subject_recent_#{self.id}", 10*60 ,  self.id)
  end

  def pop_in_redis
    RedisConnection.set(self.redis_key,  self.id)
  end

  def persist_on_s3
    self.observations.each.processNow
  end

  def self.tutorial_subject
    Subject.where(:activity_id=>'tutorial').first
  end

  def self.random_recent(user)
    list = RedisConnection.keys("subject_recent*").map{|r| r.gsub("subject_recent_","") }
    id = (list - user.seen_subject_ids.map(&:to_s)).sample
    Subject.find id
  end

  def self.random_simulation(user)
    list = RedisConnection.keys("subject_simulation*").map{|r| r.gsub("subject_simulation_","")}
    puts " active keys are #{list.to_json}"
    id = (list - user.seen_subject_ids.map(&:to_s)).sample
    Subject.find id 
  end

  def self.random_frank_subject 
    keys = RedisConnection.keys 'subject_new*'
    return nil if keys.empty?
    key = keys.sample
    subject  = JSON.parse(RedisConnection.get key)
    RedisConnection.del key
    generate_subject_from_frank(subject, key)
  end

  def self.parse_key_details(key)
     data = key.split("_")
     {observation_id: data[2],
      activity_id: data[3],
      pol: data[4].to_i,
      sub_channel: data[5].to_i
     }
  end


  def generate_simulation

    subject_attributes = self.attributes.dup
    subject_attributes.delete("_id") 
    subject_attributes.delete("random_number") 
    subject_attributes.delete("scores") 
    simulation_subject = Subject.new(subject_attributes)

    simulation_subject.has_simulation=true
    simulation_subject.zooniverse_id = nil

    simulation_subject.save

    puts " duplicated subject "
    puts simulation_subject.to_json

    simulation_observation_no = rand(self.observations.count)

    self.observations.each_with_index do |observation, index|
      attributes = observation.attributes.dup

      attributes.delete("uploaded")
      attributes.delete("zooniverse_id") 
      new_obs = Observation.new(attributes)
      puts "new obs is "
      puts new_obs
      puts new_obs.to_json
      
      new_obs.subject_id = simulation_subject.id

      if index == simulation_observation_no
        new_obs.has_simulation=true 
        sim_id = Simulation.random(:selector=>{:active=>true}).first.id
        new_obs.simulation_ids << sim_id
      end
      puts "saving observation "
      puts new_obs.to_json
      new_obs.save
    end

    GenerateTalk.perform_async simulation_subject.id

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
        beam_no  = beam['beam']
        seti_id  = beam['target']
        data_key = key.gsub("subject_new", "subject_data_new")+"_#{beam_no}"
        unless JSON.parse(RedisConnection.get(data_key)).empty?
          source = Source.find_by_seti_id(seti_id.to_s)
          source = Source.create_with_seti_id(seti_id) unless source 
          if source
            s.observations.create( :data_key => data_key,
                                   :source  => source,
                                   :beam_no => beam_no,
                                   :width => subject['width'],
                                   :height => subject['height'],
                                   :has_simulation => false
                                   )

          else 
            throw "Could not find or create Source for observation #{beam['target_id']}"
          end
        end
      end
    end
    
    GenerateTalk.perform_async s.id
    s
  end


  def redis_key 
    if has_simulation
      key = "subject_simulation_#{self.id}"
    else
      key = "subject_#{self.id}"
    end
    key 
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
