class ZooniverseUsersController < ApplicationController
  before_filter CASClient::Frameworks::Rails::GatewayFilter
  before_filter :check_login

  def badges 
    if current_user 
      respond_to do |format|
        format.json { render json: @badges.to_json }
      end
    else
      respond_with 403
    end
  end

  def awardBadge 
    if current_user
      current_user.badges[params['badge_id']] = (params['level'] || "awarded")
      respond_to do |format|
        format.json { render json: current_user.to_json }
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

  def current_logged_in_user 
    if current_user 
      respond_to do |format|
        format.json {render json: current_user.to_json(:except=>[:email, :zooniverse_user_extra_info])}
      end
    else 
     respond_to do |format|
        format.json {render json: "please log in first", :status=>403}
      end
    end
  end 

 
  def show
    @small_star_field = true  
  end


end
