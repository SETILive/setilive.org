class SubjectsController < ApplicationController

  def next_subject_for_user
    subject = nil
    if [2,2].sample ==1
      subject = get_seen_subject
    else
      puts 'getting new subject '
      subject = get_new_subject
    end

    if subject 
      respond_to do |format|
        format.json { render json: subject.to_json, :status => '200' }
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
    Subject.unseen_for_user(current_user)
  end
end
