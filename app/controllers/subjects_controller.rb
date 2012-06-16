class SubjectsController < ApplicationController
  def tutorial_subject 
    respond_to do |format|
      format.json { render json: Subject.tutorial_subject.to_json(:include => {:observations=>{:include=>:source}}), :status => '200' }
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
        if subject
          subject.save
        else
          subject = get_recent_subject
        end
      end
    end

    unless subject
      subject = Subject.random.first 
      @subjectType="archive" 
    end

    if subject 
      respond_to do |format|
        subject  = subject.as_json(:include =>{:observations=>{:include=>:source, :methods=>:data} })
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
