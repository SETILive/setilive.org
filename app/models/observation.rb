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
  # 2. If an ON followup pending on the observation, triggers the next stage if
  # any real signals are found in it.
  # 3. If an OFF followup is pending on the observation, triggers the next stage
  # if either no multi-beam signals are found or only real signals are found.
  # New followups are triggered for the latter case.
  def check_followup
    is_followup = subject.follow_up_id > 0
    if is_followup
      f = Followup.where(:signal_id_nums => subject.follow_up_id ).first
      obs_type = f.current_stage + 1
    else
      f = nil
      obs_type = 0
    end
    is_beam = ( is_followup and f.observations.sort(:created_at).last.beam_no == beam_no )
    is_onx = ( is_beam and obs_type.odd? )
    is_offx = ( is_beam and obs_type.even? )
    is_empty = ( signal_groups.count == 0 )
    
    if ( is_empty and is_offx )
      trigger_followup(f, nil, false)
    else
      # SIGGROUPS in obs
      multi = false # Initialize no-reals flag
      sig_grp_tmp = nil
      signal_groups.each do |sig_grp|
        real = sig_grp.is_real?
        sig_grp_tmp = sig_grp if real # Remembers last real signal group
        if ( ( !is_onx or is_offx ) and real )
          trigger_followup( Followup.new(), sig_grp, true )
        end
        multi ||= !real 
      end
      if ( is_onx and !multi )
        trigger_followup( f, sig_grp_tmp, true )
      end
      if ( is_offx and !multi )
        trigger_followup( f, nil, false)
      end
    end
  end
  
  def trigger_followup f, sig_grp, on    
    signal_id_num = subject.follow_up_id
    f.observations << self  
    f.signal_groups << sig_grp if on
    
    # Select a unique signal_id_number for the followup message
    # Normally, current timestamp in seconds. If followup within 2 seconds of
    # last one increments by 1. Avoids duplication if multiple followups.
    sig_id_num = RedisConnection.get( "followup_last_num")
    if sig_id_num
      sig_id_num += 1
    else
      sig_id_num = Time.now.utc.to_i
    end
    RedisConnection.setex "followup_last_num", 2, sig_id_num
    
    f.signal_id_nums << sig_id_num
    f.trigger_next_stage
    puts "trying to save"
    if f.save 
      puts "triggering "
      f.trigger_follow_up on
    else
      puts "not triggered"
    end
  end

  # def update_signal_groups
  #   if subject.classification_count > 10
  #     new_signals = self.subject_signals.where(:signal_group=>nil).collect{|ss| ss.to_fof}
  #     groups  = self.signal_group.collect{ |signal_group| signal_group.to_fof }
  #     groups  = groups + new_signals
  #     fof_finder = FOFFinder.create_with_groups groups, 1
  #     fof_finder.find_groups 
  #   end
  # end
  
end
