class Observation
  include MongoMapper::Document

  key :type , String, :validate_in => ['inital','on','off','tutorial', 'simulation']
  key :data_key, String
  key :data_url, String
  key :image_url, String
  key :simulation_url, String
  key :simulation_thumb_url, String

  key :simulation_reveal_url, String
  key :thumb_url, String
  key :beam_no, Integer
  key :zooniverse_id, String
  key :width, Integer
  key :height, Integer
  key :uploaded, Boolean, :default => false
  key :has_simulation, Boolean, :default=>false
  key :simulation_ids , Array
  key :pol, Integer # Note: Added for rendering version 2 with pol combining.
                    # 0 => X, 1 => Y, 2 => I (X,Y combined).
  
  belongs_to :source 
  belongs_to :subject
  many       :subject_signals
  has_one    :signal_finder

  many :simulations, :in => :simulation_ids
  many :signal_groups
  
  scope :simulation , where(:has_simulation=>true)
  scope :real       , where(:has_simulation=>false)
  
  belongs_to :follow_up
  before_create :create_zooniverse_id
  
  timestamps! 


  def create_zooniverse_id
    self.zooniverse_id = "OSL#{ beam_no || 0 }#{ subject.zooniverse_id[4..-1] }"
  end

  def process 
      ObservationUploader.perform_async self.id
    end

  def processNow 
    ObservationUploader.new.perform self.id
  end

  def get_data
     data = JSON.parse(RedisConnection.get(data_key)) unless uploaded
  end

  def data
    if data_url?
      data = HTTParty.get data_url
      data= JSON.parse(data.match(/\[.*\]/).to_s)
    elsif RedisConnection.exists data_key
      data = JSON.parse(RedisConnection.get(data_key))
    end 
    data
  end


  def data_for_display
    JSON.parse(RedisConnection.get(data_key)) unless uploaded 
  end
  
  # Multi-level beam(observation)-based followup trigger logic.\
  # 
  # 1. If no followup pending on the observation, triggers a separate followup for 
  # any real signals signals found.
  # 2. If an ONx followup pending on the observation, triggers the next stage if
  # any real signals are found in it. Reports the one with highest confidence.
  # 3. If an OFFx followup is pending on the observation, triggers the next stage
  # if no signals are found in it.
  def check_followup fup
    if fup
      if ( fup.current_stage + 1 ).even?
        # OFFx: Trigger only on no signals in candidate beam
        trigger_followup(fup, nil, false) if signal_groups.count == 0 
      else
        # ONx: Trigger on highest confidence valid signal
        confidence = 0
        sig_grp_best = nil
        signal_groups.each do |sig_grp|
          real = sig_grp.is_real?          
          if real && ( sig_grp.confidence > confidence )
            sig_grp_best = sig_grp
            confidence = sig_grp.confidence
          end
        end
        trigger_followup( fup, sig_grp_best, true ) if sig_grp_best
      end
    else
      # ON: Trigger on all valid signals
      signal_groups.each do |sig_grp|
        trigger_followup( Followup.new(), sig_grp, true ) if sig_grp.is_real?
      end
    end
  end
  
  def trigger_followup f, sig_grp, on    
    subject.done
    signal_id_num = subject.follow_up_id
    f.observations << self  
    f.signal_groups << sig_grp if on
    
    # Select a unique signal_id_number for the followup message
    # Normally, current timestamp in seconds. If followup within 2 seconds of
    # last one increments by 1. Avoids duplication if multiple followups.
    sig_id_num = RedisConnection.get( "followup_last_num").to_i
    if sig_id_num > 0
      sig_id_num += 1
    else
      sig_id_num = Time.now.utc.to_i
    end
    RedisConnection.setex "followup_last_num", 2, sig_id_num
    
    f.signal_id_nums << sig_id_num
    f.trigger_next_stage
    puts "Triggering..."
    msg = f.trigger_follow_up on
    f.followup_msgs << msg
    puts "Trying to save..."
    if f.save
      puts "...saved."
    else
      puts "...not saved"
    end
    
    update_user_followups( sig_id_num )
    
  end
  
  def update_user_followups( sig_id_num )
    classifications = self.subject.classifications
    classifications.each do |c|
        user = ZooniverseUser.find(c.zooniverse_user_id)
        user.update_followups( sig_id_num )        
      end 
  end

end
