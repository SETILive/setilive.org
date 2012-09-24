class SignalGroup
  include MongoMapper::Document
  key :intercept, Float
  key :mid, Float
  key :gradient, Float
  key :angle, Float
  key :confidence, Float 
  key :drift, Float 
  key :start_freq , Float 
  key :subject_signal_ids, Array
  
  key :characteristics, Array
  key :real, Boolean, :default => false 

  belongs_to :observation
  belongs_to :source
  belongs_to :follow_up
  
  many :subject_signals, :in => :subject_signal_ids

  timestamps! 
  before_save :calc_characteristics 

  def calc_characteristics
    self.drift = calc_drift
    self.start_freq = calc_start_freq  
  end
  
  def calc_drift
    # In Hz / second
    Math.tan(angle)*( 410.0 / 93.0 ) /  (758 / 533 )
  end
  
  def calc_start_freq
    # Relative to center frequency in Hz at start of waterfall (y=0)
    ( mid - 758.0 / 2.0 ) * ( 533.0 / 2.0 ) - calc_drift * ( 93.0 / 2.0 )
  end
  
  def is_real?
    single_beam? and isnt_vertical?
  end

  def single_beam?
    !multi_beam?
  end
  
  def isnt_vertical?
    !is_vertical?
  end
  
  def multi_beam?
    observation.subject.observations.each do |test_obs|
      unless test_obs.id == observation.id
        test_obs.signal_groups.each do |signal_group| 
          if (signal_group.angle - angle).abs < 0.079 and (signal_group.mid - mid).abs < 10
            return true
          end 
        end
      end
    end
    return false
  end
  
  def is_vertical?
    angle > -0.005 and angle < 0.005 # Two pixels
  end

  def trigger_followup?
    unless check_vertical or in_one_beam==false 
      return true
    end
    return false 
  end
  
end
