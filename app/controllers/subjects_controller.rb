class SubjectsController < ApplicationController
  def tutorial_subject 
    respond_to do |format|
      format.json { render json: Subject.tutorial_subject.to_json(:include => {:observations=>{:include=>:source}}), :status => '200' }
    end
  end
  
  def fake_followup_trigger_2
    # Enables a special user to repeatedly be served their current subject
    # to effectively act as a group of users classifying it.
    
    # Has special user started a fake followup window?
    ffid = RedisConnection.get('fake_followup')    
    if ffid
      #If so, replace the key with one allowing repeated classifying.
      RedisConnection.setex('fake_followup_2', 240, ffid )
      RedisConnection.del( 'fake_followup' )
      render :inline => 
        "fake followup 2 started on activity_id=" << 
        Subject.find(ffid).activity_id
    else
      render :inline => "fake followup 2 not armed"
    end
    
  end
  
  def fake_followup_trigger
    ffid = RedisConnection.get('fake_followup')
    
    if ffid
      s = Subject.find(ffid)
      if s        
        if s.follow_up_id > 0
          f = Followup.where(:signal_id_nums => s.follow_up_id ).first
          last_beam_no = f.observations.sort(:created_at).last.beam_no
          obs = s.observations.where(:beam_no => last_beam_no).first
          obs_type = f.current_stage + 1
        else
          f = nil
          obs = s.observations.first
          last_beam_no = obs.beam_no
          obs_type = -1
        end
        if obs
          if ( obs_type.odd? )
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
    @subjectType = "new"

    # For follow-up testing this user pulls a new subject from frank
    if current_user.name == 'bhima1'
      # Has the fake followup 2 window been triggered?
      ffid = RedisConnection.get('fake_followup_2')      
      if ffid
        # In a followup 2 window, grab the same subject
        subject = Subject.find(ffid)
      else
        # Grab a subject and start a fake followup trigger window
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
    end
    
    if rand() < 0.1 and subject == nil
      subject = get_simulation_subject
    end

    if subject == nil
      if rand() < 0.8
        subject = get_recent_subject
        subject = get_new_subject unless subject
      else
        subject = get_new_subject
        subject = get_recent_subject unless subject
      end
    end

    unless subject
      subject = Subject.random(:selector => {:status => "active"}).first 
      @subjectType = "archive" 
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
