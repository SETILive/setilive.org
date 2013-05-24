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
  key :parms, Hash, 
          :default => { drift_max: 1.0, # Hz/sec/GHz Max Doppler
                        drift_min: 0.007, # Hz/sec Vertical criterion
                        drift_tol: 1.0, # Inter-beam matching, drift
                        mid_tol: 0.05 # Inter-beam matching, normalized x
                      }

  belongs_to :observation
  belongs_to :source
  belongs_to :follow_up
  
  many :subject_signals, :in => :subject_signal_ids

  timestamps! 
  
  before_create :load_parms
  
  before_save :calc_characteristics 

  def load_parms
    if ( temp = RedisConnection.get('signal_group_parms') )
      self.parms = JSON.parse( temp )
    end
  end
  
  def calc_characteristics
    self.drift = calc_drift
    self.start_freq = calc_start_freq  
  end
  
  def calc_drift
    # In Hz / second
    # NOTE: SonATA DX vertical limits are too precise for SETILive measurement
    # (i.e., < 0.13 degrees on waterfall), so reported value is always outside
    # limits. Also test for nil. Gets called before parms is defined apparently.
    temp = -( observation.subject.freq_range / 93.0 ) * gradient
    ( temp.abs > parms[:drift_min] ) ? temp : 
        ( temp > 0  ? 1.0 : -1.0 ) * parms[:drift_min] * 1.2
  end
  
  def calc_start_freq
    # Relative to center frequency in Hz at start of waterfall (y=0)
    observation.subject.location['freq'] +
      ( mid + 0.5 / gradient - 0.5 ) * observation.subject.freq_range / 1_000_000.0
  end
  
  def is_real?
    drift.abs < parms[:drift_max] * start_freq / 1000.0 &&
    drift.abs > parms[:drift_min] &&
    single_beam( parms[:drift_tol], parms[:mid_tol] )
  end
  
  def single_beam( d_drift, d_mid )
    observation.subject.observations.each do |test_obs|
      unless test_obs.id == observation.id
        test_obs.signal_groups.each do |signal_group| 
          if ( (signal_group.drift - drift).abs < d_drift ) and 
             ( (signal_group.mid - mid).abs < d_mid )
            return false
          end 
        end
      end
    end
    return true
  end
    
end
