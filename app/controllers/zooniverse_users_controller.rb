class ZooniverseUsersController < ApplicationController
  before_filter :check_login
  before_filter :authenticate, :only => [:index]


  def index 
    respond_to do |format|
      format.json { render json: ZooniverseUser.all.to_json({:except=>[:api_key,:email,:badges], :methods=>:badgeDetails}) }
    end
  end

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
    puts params

    @current_user = current_user
    if @current_user
      @current_user.badges.push({ :id => params[:id], :level => params[:level] })
      # @current_user.total_badge_count= @current_user.total_badge_count+1
      @current_user.save

      respond_to do |format|
        format.json { render json: @current_user.to_json }
      end
    else
      respond_with 403
    end
  end

  def recents 
    respond_to do |format|
      format.json { render json: current_user.seen_observations.to_json(:except=>:data, :include=>[:source,:subject]) }
    end
  end

  def favourites 
    respond_to do |format|
      format.json { render json: current_user.favourites.to_json(:except=>:data, :include=>[:source,:subject]) }
    end
  end

  def seen_tutorial
    current_user.seen_tutorial=true
    current_user.save
    respond_to do |format|
      format.json { render json: "" }
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


  def sweeps_change 
    user = current_user
    user.sweeps_status='none'
    user.agreed_to_sweeps_rules= false
    user.agreed_to_email = false
    user.zooniverse_user_extra_info.delete if user.zooniverse_user_extra_info
    user.save
    redirect_to '/sweeps'
  end

  def sweeps_out
    user = current_user
    user.sweeps_status='out'
    user.agreed_to_sweeps_rules= false
    user.agreed_to_email = false
    user.zooniverse_user_extra_info.delete if user.zooniverse_user_extra_info
    user.save
    redirect_to '/profile'
  end


  def register_talk_click
    if current_user
      current_user.increment(:talk_click_count => 1)
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
