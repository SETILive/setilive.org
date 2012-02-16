class AccountsController < ApplicationController
  before_filter CASClient::Frameworks::Rails::GatewayFilter

  def login
    @cas_client = CASClient::Frameworks::Rails::Filter.client
    @return_to = "http://#{request.host}:#{request.port}/sweeps"
    puts @return_to
    @small_star_field = true  
  end
  
  def logout
    @current_user = @current_zooniverse_user = nil
    session.clear
    cas_logout
  end

  def sweeps 
    @current_user = current_user
    # puts params 
    if (params[:first_name])
      @current_user.sweeps_status = 'in'
      # @current_user.zooniverse_user_extra_info.zooniverse_user_extra_info= ZooniverseUserExtraInfo.create(params)
      @current_user.save
      redirect_to root_path
    elsif @current_user
      redirect_to root_path if @current_user.sweeps_status == 'out'
    end 
  end
  
  def signup
    puts params

    @messages ||= []

    unless params[:password] == params[:password_confirmation]
      @messages << "Password and password confirmation don't match"
      flash.now[:error] = @message
      @cas_client = CASClient::Frameworks::Rails::Filter.client
      render :login
      return
    end

    create_zooniverse_user

    if @successful && params[:return_to]
      redirect_to "http://#{request.host}:#{request.port}/sweeps"
    elsif @successful
      redirect_to "http://#{request.host}:#{request.port}/sweeps"
    else
      flash.now[:error] = @messages
      @cas_client = CASClient::Frameworks::Rails::Filter.client
      render :login
    end

  end


  def create_zooniverse_user
    params['name'] = "#{ params['firstname'] } #{ params['lastname'] }"
    hash = params_for %w(login email name password password_confirmation)
    result = Zooniverse.create_user(hash)
    
    @successful 
    
    @successful = result['success']
    @messages +=  result['messages'] if result['messages']

    if @successful
      session[:cas_extra_attributes] = { 'id' => result['user']['id'] }
      session[:zooniverse_user] = result['user']['login']
      current_zooniverse_user
    end
  end

  def params_for(keys)
    values = params.values_at *keys
    Hash[ *keys.zip(values).flatten ]
  end
end
