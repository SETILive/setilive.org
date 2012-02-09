class UsersController < ApplicationController
  before_filter CASClient::Frameworks::Rails::Filter 


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

  
end
