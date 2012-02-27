class SubjectsController < ApplicationController
  before_filter CASClient::Frameworks::Rails::Filter

  def tutorial_subject 
    respond_to do |format|
      format.json { render json: Subject.tutorial_subject.to_json(:include => :observations), :status => '200' }
    end
  end


  def next_subject_for_user
    subject = nil
     
    if [1,1].sample ==1
      subject = get_seen_subject
      subject = get_new_subject unless subject
    else
      subject = get_new_subject
      if subject
        subject.save
      else
        subject = get_seen_subject
      end
    end


    if subject 
      respond_to do |format|
        format.json { render json: subject.to_json(:include => :observations), :status => '200' }
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

  def get_seen_subject
    # Subject.unseen_for_user(current_user)
    Subject.random.first
    # Subject.first
  end
end
