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
      sig_group = SignalGroup.create( angle: 0.25,
                                      observation: obs.first,
                                      source: obs.first.source )
      sig_group.check_real
    else
      render :inline => "no subject found"
    end
    
  end
  def next_subject_for_user
    subject = nil
    @subjectType="new"


    if ['stuart.lynn','lnigra'].include? current_user.name and params[:subject_id]
      subject = Subject.find(params[:subject_id])
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
      subject = Subject.random.first 
      @subjectType="archive" 
    end

    if subject 
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
    Subject.random.first
    # Subject.first
  end
end
