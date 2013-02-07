class ZooniverseUsersController < ApplicationController
  before_filter :check_login, :except=>[:index, :current_logged_in_user, 
                                        :telescope_notify_users]
  before_filter :authenticate, :only => [:index]
  
  skip_before_filter :browser, :only => [:telescope_notify_users]
  
  def index 
    respond_to do |format|
      format.json {render json: ZooniverseUser.science_report}
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
    @current_user = current_user
    if @current_user
      @current_user.badges.push({ :id => params[:id], :level => params[:level] })
      # @current_user.total_badge_count= @current_user.total_badge_count+1
      @current_user.save

      respond_to do |format|
        format.json { render json: @current_user.as_json }
      end
    else
      respond_with 403
    end
  end

  def recents 
    respond_to do |format|
      format.json { render json: current_user.recent_observations(page: params[:page].to_i).as_json }
    end
  end

  def live_classification_stats
    if current_user
      @unseen = RedisConnection.keys('*_subject_new*').count
      list = RedisConnection.keys("subject_recent*").map{|r| r.gsub("subject_recent_","") }
      @unseen += (list - current_user.seen_subject_ids.map(&:to_s)).count
      @seen = RedisConnection.get("live_subjects_seen_#{current_user.id}")
      @seen = 0 unless @seen
      respond_to do |format|
        format.html
        format.json {render :json=> {seen: @seen, unseen: @unseen}.to_json}
      end
    end
  end
  
  def favourites 
    respond_to do |format|
      format.json { render json: current_user.recent_favourites(page: params[:page].to_i).as_json }
    end
  end

  def seen_tutorial
    current_user.seen_tutorial=true
    current_user.save
    respond_to do |format|
      format.json { render json: "" }
    end
  end

  def seen_marking_notice
    current_user.seen_marking_notice=true
    current_user.save
    respond_to do |format|
      format.json { render json: "" }
    end
  end

  def current_logged_in_user 
    if current_user 
      respond_to do |format|
        format.json {render json: current_user.as_json}
      end
    else 
     respond_to do |format|
        format.json {render json: "false"}
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
        format.json {render json: current_user.as_json }
      end
    else 
      respond_to do |format|
        format.json {render json: "please log in first", :status=>403}
      end
    end 
  end
 
  def telescope_toggle_notify
    if current_user
      current_user.telescope_toggle_notify
      respond_to do |format|
        format.json {render json: current_user.telescope_notify}
      end
    else
      respond_to do |format|
        format.json {render json: "please log in first", :status=>403}
      end
    end
      
  end

  def telescope_notify_users
    puts params[:passwd]
    if params[:passwd] == '***REMOVED***'
      temp = RedisConnection.get("telescope_notify_parms")
      parms = temp ? 
              JSON.parse( temp ) : 
              JSON.parse( {:chunk_size => 100, :time_between => 15 }.to_json)
      chunk_size = parms["chunk_size"]
      delta_t = parms["time_between"]
      skipnum = 0
      delay = 0
      next_time = (RedisConnection.get("next_status_change").to_f/1000.0).to_i
      unless next_time == 0
        respond_to do |format|
          format.json {render json: "email process started"}
        end
        begin
          users = ZooniverseUser.where(
            :telescope_notify => true).limit(chunk_size).skip(skipnum).to_a
          user_emails = []
          users.each { |u| user_emails << u.email}
          unless user_emails.count == 0
            TelescopeScheduleNotify.perform_in( 
            delay.minutes.from_now, user_emails, next_time )
          end
          skipnum += chunk_size
          delay += delta_t
        end while users.count != 0
      else
        respond_to do |format|
          format.json {render json: "emails not sent. Nothing is scheduled"}
        end
      end
    else      
      respond_to do |format|
        format.json {render json: "bad parameters", :status=>406}
      end      
    end
  end
 
  def show
    @small_star_field = true  
  end
end
