class Followup
  include MongoMapper::Document
  key :current_stage , Integer , :default => 0

  has_many :signal_groups 
  has_many :observations
  
  belongs_to :source 
  
  timestamps!
  
  def inital_signal
    signal_groups.first
  end

  def trigger_next_stage 
    self.current_stage = self.current_stage + 1
    notify_someone if self.current_stage == 5 
  end

  def notify_someone
  end

  def self.trigger_fake_follow_up(subject)

    beam_no      = 1
    source       = subject.observations.first.source
    observation  = subject.observations.first
    subject      = subject
    beam_no      = subject.observations.first.beam_no
    # signal       = signal_groups.last
    dx_no        = Subject.beam_to_dx beam_no
    
    
    reply = { signalIdNumber: 2,
              activityId: subject.activity_id, 
              targetId: source.seti_ids.first,
              beamNumber: observation.beam_no,
              dxNumber: dx_no,
              pol: (subject.pol==0 ? "right" : "left"),
              subchanNumber: subject.sub_channel,
              type: "CwP",
              rfFreq: subject.central_freq,
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
              origSignalIdNumber: 1
             }
  
    RedisConnection.setex "follow_up_#{1234}", 30, reply.to_json
    # Pusher["telescope"].trigger( "followUpTrigger", "")

  end
  
  def trigger_follow_up
    beam_no      = 1
    source       = signal_groups.last.source
    observation  = signal_groups.last.observation
    subject      = observation.subject
    beam_no      = observation.beam_no
    signal       = signal_groups.last
    dx_no        = Subject.beam_to_dx beam_no
    
    
    reply = { signalIdNumber: 2,
              activityId: subject.activity_id, 
              targetId: source.seti_ids.first,
              beamNumber: observation.beam_no,
              dxNumber: dx_no,
              pol: (subject.pol==0 ? "right" : "left"),
              subchanNumber: subject.sub_channel,
              type: "CwP",
              rfFreq: signal.calc_start_freq,
              drift: signal.calc_drift,
              width: 5,
              sigClass: "Cand",
              power: 200,
              reason: "Confrm",
              containsBadbands: "no",
              activityStartTime: (Time.at(subject.location["time"]/1_000_000_000) + 5.hours).strftime("%Y-%m-%d %H:%M:%S") ,
              origDxNumber: dx_no,
              origActivityId: -1, #self.orig_activity_id,
              origActivityStartTime: -1,# self.orig_activity_start_time,
              origSignalIdNumber: 1
             }
  
    RedisConnection.setex "follow_up_#{self.id}", 30, reply.to_json
    Pusher["telescope"].trigger( "followUpTrigger", "")
    # puts  reply.to_json
  end
  
  def trigger_follow_up_off
    beam_no = 1
  
    reply = { signalIdNumber: 2,
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
