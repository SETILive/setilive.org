class Followup
  include MongoMapper::Document
  key :current_stage , Integer , :default => -1
  key :signal_id_nums , Array
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

  def self.trigger_fake_follow_up(subject)

    beam_no      = 1
    source       = subject.observations.first.source
    observation  = subject.observations.first
    subject      = subject
    beam_no      = subject.observations.first.beam_no
    # signal       = signal_groups.last
    dx_no        = Subject.beam_to_dx beam_no
    
    
    reply = { signalIdNumber: subject.location["time"]/10**9,
              activityId: subject.activity_id, 
              targetId: source.seti_ids.first,
              beamNumber: observation.beam_no,
              dxNumber: dx_no,
              pol: (subject.pol==0 ? "right" : "left"),
              subchanNumber: subject.sub_channel,
              type: "CwP",
              rfFreq: subject.location["freq"],
              drift: 0.7,
              width: 5,
              sigClass: "Cand",
              power: 200,
              reason: "Confrm",
              containsBadbands: "no",
              activityStartTime: (Time.at(subject.location["time"]/1_000_000_000) + 5.hours).strftime("%Y-%m-%d %H:%M:%S") ,
              origDxNumber: dx_no,
              origActivityId: -1, #self.orig_activity_id,
              origActivityStartTime: -1,# self.orig_activity_start_time,
              origSignalIdNumber: 0
             }
  
    RedisConnection.setex "follow_up_#{1234}", 30, reply.to_json
    # Pusher["telescope"].trigger( "followUpTrigger", "")

  end
  
  def trigger_follow_up(is_on)
    obss         = self.observations.sort(:created_at.desc).limit(2)
    observation  = obss.first
    obs_prev     = obss.last
    signal       = self.signal_groups.sort(:created_at.desc).first
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
    sig_freq  = ( is_on ? 
                  signal.start_freq + subject.location["freq"]: 
                  signal.start_freq + signal.drift * t_delta
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
              reason: (self.current_stage==0 ? "Confrm" : "RConfirm" ),
              containsBadbands: "no",
              activityStartTime: (Time.at(t_act)).strftime("%Y-%m-%d %H:%M:%S") ,
              origDxNumber: Subject.beam_to_dx( obs_prev.beam_no ),
              origActivityId: subj_prev.activity_id,
              origActivityStartTime: Time.at(t_act_prev).strftime("%Y-%m-%d %H:%M:%S") ,
              origSignalIdNumber: sig_id_prev
             }
  
    RedisConnection.setex "follow_up_#{self.id}", 30, reply.to_json
    if Rails.env.development?
      #Fake followup substitute for ATA echoing last followup signalIdNumber
      RedisConnection.setex "last_followup_signal_id", 600, signal_id_nums.last
      puts  reply.to_json
    else
      Pusher["telescope"].trigger( "followUpTrigger", "")
    end
  end
  
  def trigger_follow_up_off
    beam_no = 1
  
    reply = { signalIdNumber: Time.now.to_i,
              activityId: self.observations.first.subject.activity_id, 
              targetId: self.observations.first.source.seti_ids.first,
              beamNumber: beam_no,
              dxNumber: beam_to_dx(beam_no),
              pol: (self.pol==0 ? "right" : "left"),
              subchanNumber: self.sub_channel,
              type: "CwP",
              rfFreq: self.location["freq"],
              drift: 0.1,
              width: 5,
              sigClass: "Cand",
              power: 200,
              reason: "RCnfrm",
              containsBadbands: "no",
              activityStartTime: (Time.at(self.location["time"]/1_000_000_000) + 5.hours).strftime("%Y-%m-%d %H:%M:%S") ,
              origDxNumber: beam_to_dx(beam_no),
              origActivityId: -1, #self.orig_activity_id,
              origActivityStartTime: -1,# self.orig_activity_start_time,
              origSignalIdNumber: 1
             }
  
    RedisConnection.setex "follow_up_#{self.id}", 30, reply.to_json
    # puts  reply.to_json
  end

end
