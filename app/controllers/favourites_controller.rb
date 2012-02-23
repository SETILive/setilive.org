class FavouritesController < ApplicationController
  before_filter CASClient::Frameworks::Rails::Filter

  def create
    user = current_user
    subject = Subject.find(params[:subject_id])

    respond_to do |format|
      if subject and user.push(:favourite_ids=>subject.id)
        format.json { render json: user, status: :created}
      else
        format.json { render json: '', status: :unprocessable_entity }
      end
    end
  end

  def destroy
    user = current_user
    subject = Subject.find(params[:subject_id])
    
    respond_to do |format|
      if subject and user.pop(:favourite_ids=>subject.id)
        format.json {render json: user, status: :destroyed }
      else
        format.json { render json: '', status: :unprocessable_entity }
      end
    end
  end

end
