class SubjectsController < ApplicationController
  def tutorial_subject 
    respond_to do |format|
      format.json { render json: Subject.tutorial_subject.to_json(:include => {:observations=>{:include=>:source}}), :status => '200' }
    end
  end

  def trigger_followup
    s = Subject.random_recent ZooniverseUser.where(:name=>"stuart.lynn").first
    if s 
      Followup.trigger_fake_follow_up s
      render :inline => "triggered followup"
    else
      render :inline => "no recent subjects" 
    end
  end
  
  def trigger_followup_2
    #Get a subject
    if Rails.env.development?
      s = Subject.random.first
    else
      s = Subject.random_recent ZooniverseUser.where(:name=>"stuart.lynn").first
    end
    
    if s
      render :inline => "found subject: activity_id=" << s.activity_id
      if Rails.env.development?
        puts "subject", s.original_redis_key #Use to find subject in database
        #Substitute for ATA echoing last followup signalIdNumber
        last_followup_signal_id = RedisConnection.get "last_followup_signal_id"
        if last_followup_signal_id
          s.follow_up_id = last_followup_signal_id.to_i
        else
          s.follow_up_id = 0
        end
        s.save
        puts "followup_signal_id", s.follow_up_id
      end
      obs = s.observations
      puts "observations", obs.first
          sig_group = SignalGroup.create( angle: 0.20,
                                          mid: 758.0 / 2.0,
                                          observation: obs.first,
                                          source: obs.first.source )
      sig_group.check_real
    else
      render :inline => "no subject found"
    end
    
  end

  def fake_followup_trigger
    ffid = RedisConnection.get('fake_followup')
    
    if ffid
      s = Subject.find(ffid)
      if s        
        if Rails.env.development?
          #Substitute for ATA echoing last followup signalIdNumber
          last_followup_signal_id = RedisConnection.get("last_followup_signal_id").to_i 
          last_followup_signal_id = 0 unless last_followup_signal_id
          s.follow_up_id = last_followup_signal_id
        else
          last_followup_signal_id = s.follow_up_id
        end
        if last_followup_signal_id > 0
          f = Followup.where(:signal_id_nums => s.follow_up_id ).first
          s.observation_id = f.current_stage + 1 if Rails.env.development?
          s.follow_up_id = last_followup_signal_id
        else
          f = nil
          s.observation_id = 0 if Rails.env.development?
          s.follow_up_id = 0
        end
        s.save
        if s.follow_up_id > 0
          last_beam_no = f.observations.last.beam_no
          obs = s.observations.where(:beam_no => last_beam_no).first
        else
          obs = s.observations.first
        end
        if obs
          if ( s.observation_id == 0 or s.observation_id.odd? )
            sig_group = SignalGroup.create( angle: 0.20,
                                            mid: 758.0 / 2.0,
                                            observation: obs,
                                            source: obs.source )
          end
          render :inline => "fake followup started with subject: activity_id=" << s.activity_id
          s.check_for_signals
        else
          render :inline => "fake followup started but no subject found with tracked beam"
        end
      else
        render :inline => "fake followup armed but no subject found"
      end
    else
      render :inline => "fake followup not armed"
    end
    
  end

  def next_subject_for_user
    subject = nil
    @subjectType="new"

    # For follow-up testing this user pulls a new subject from frank
    if current_user.name == 'bhima1'
      unless RedisConnection.get('fake_followup')
        info = Subject.pull_random_frank_key
        if info
          subject = Subject.generate_subject_from_frank(info[0], info[1])
          RedisConnection.setex('fake_followup', 90, subject.id) if subject
        else
          subject = get_recent_subject
          RedisConnection.setex('fake_followup', 90, subject.id) if subject
        end
      end
    end
    
    if rand() < 0.1 and subject==nil
      subject = get_simulation_subject
    end

    if subject==nil
      if rand()<0.8
        subject = get_recent_subject
        subject = get_new_subject unless subject
      else
        subject = get_new_subject
        subject = get_recent_subject unless subject
      end
    end

    unless subject
      subject = Subject.random(:selector=>{:status=>"active"}).first 
      @subjectType="archive" 
    end
   
    if subject 
    
      # Update user's seen_subject list here instead of after classification
      # in zooniverse_user.update_classification_stats. Better here since at
      # this point, the user will see the subject whether they classify or not.
      # Also should eliminate repeated serving/refresh of a bad recent subject.
      updater = current_user.update_seen(subject)
      current_user.collection.update({ :_id => current_user.id }, updater)
         
      respond_to do |format|
        subject  = subject.as_json(:include =>{:observations=>{:include=>:source, :methods=>:data_for_display, :except=>:data} })

        subject['subjectType']= @subjectType
        format.json { render json: subject.to_json , :status => '200' }
      end
    else
      respond_to do |format|
        format.json { render json: '', :status => '404' }
      end
    end
  end

  def get_new_subject
    Subject.random_frank_subject
  end

  def get_simulation_subject
    Subject.random_simulation(current_user)
  end

  def get_recent_subject
    Subject.random_recent(current_user)
  end
  def get_seen_subject
    # Subject.unseen_for_user(current_user)
    Subject.random(:selector=>{:status=>"active"}).first 
    # Subject.first
  end
end
