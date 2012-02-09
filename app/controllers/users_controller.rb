class UsersController < ApplicationController
  before_filter :signed_id

  def badges 
    if current_user 
      respond_to do |format|
        format.json { render json: @badges.to_json }
      end
    else
      respond_with 403
    end
  end

  def favourites 
    respond_to do |format|
      format.json { render json: current_user.badges.to_json }
    end
  end

  def current_user 

  end 

  def login

  end

  def logout 

  end
end
