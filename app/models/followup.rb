class Followup
  include MongoMapper::Document
  key :current_stage , Integer , :default => -1
  key :signal_id_nums , Array
  key :followup_msgs, Array
  has_many :signal_groups
  has_many :observations
  
  belongs_to :source 
  
  timestamps!
  
  def inital_signal
    signal_groups.first
  end

  def trigger_next_stage 
    self.current_stage = self.current_stage + 1
    notify_someone if self.current_stage == 10 
  end

  def notify_someone
    puts "NOTIFY SOMEONE"
  end
  
  def trigger_follow_up(is_on)
    obss         = self.observations.sort(:created_at.desc).to_a
    observation  = obss[0]
    obs_prev     = obss[1] ? obss[1] : obss[0]
    signal       = self.signal_groups.sort(:created_at.desc).to_a[0]
    source       = signal.source
    beam_no      = observation.beam_no
    subject      = observation.subject
    subj_prev    = obs_prev.subject
    sig_id_prev  = (self.current_stage == 0 ? 
        signal_id_nums[0] : subject.follow_up_id )
    t_act = subject.location["time"] / 1_000_000_000 # sec
    t_act_prev = subj_prev.location["time"] / 1_000_000_000 # sec
    t_delta = ( t_act - t_act_prev ) # sec
    sig_drift = signal.drift
    sig_freq  = is_on ? 
      ( ( signal.start_freq / 1_000_000 ) + subject.location["freq"] ): 
      ( ( signal.start_freq + signal.drift * t_delta ) / 1_000_000 
                          + subj_prev.location["freq"] )
    
    reply = { signalIdNumber: signal_id_nums.last,
              activityId: subject.activity_id, 
              targetId: source.seti_ids.first,
              beamNumber: observation.beam_no,
              dxNumber: Subject.beam_to_dx( observation.beam_no ),
              pol: "both",
              subchanNumber: subject.sub_channel,
              type: "CwP",
              rfFreq: sig_freq,
              drift: sig_drift,
              width: 5,
              sigClass: "Cand",
              power: 200,
              reason: (self.current_stage==0 ? "Confrm" : "RConfrm" ),
              containsBadbands: "no",
              activityStartTime: (Time.at(t_act)).strftime("%Y-%m-%d %H:%M:%S") ,
              origDxNumber: Subject.beam_to_dx( obs_prev.beam_no ),
              origActivityId: subj_prev.activity_id,
              origActivityStartTime: Time.at(t_act_prev).strftime("%Y-%m-%d %H:%M:%S") ,
              origSignalIdNumber: sig_id_prev
             }
  
    RedisConnection.setex "follow_up_#{self.id}", 30, reply.to_json
    key = RedisConnection.keys("fake_followup*") ? "fakeFollowUpTrigger" : "followUpTrigger"
    on_request = self.current_stage == 0 ? is_on : !is_on
    key_value = 'Level ' + 
                ( ( 1.0 * self.current_stage + 2.5 ) / 2.0 ).to_int.to_s +
                (on_request ? ' ON' : ' OFF')
    Rails.env.development? ? 
      Pusher['dmode-dev-telescope'].trigger( key, key_value) : 
      Pusher["dev-telescope"].trigger( key, key_value)
    reply.to_json
  end

end
