class AccountsController < ApplicationController
  before_filter CASClient::Frameworks::Rails::GatewayFilter

  def login
    @cas_client = CASClient::Frameworks::Rails::Filter.client
    @return_to = "http://#{request.host}:#{request.port}/sweeps"
    @from_discovery=true if params['discovery']
    @small_star_field = true  
  end
  
  def logout
    @current_user = @current_zooniverse_user = nil
    session.clear
    cas_logout
  end

  def sweeps 
    @current_user = current_user
    @current_user.increment(total_logins: 1)
    # if the current user hasnt signed up or opted out of the sweeps 
    if current_user.sweeps_status != 'none' 
      if current_user.seen_tutorial
        redirect_to '/classify'
      else 
        redirect_to '/tutorial'
      end
    end
  end

  def sweeps_submit
    @current_user = current_user

    if (params['register.x'] and params['offical-rules-agree']=='on')
      @current_user.sweeps_status = 'in'
      @current_user.agreed_to_sweeps_rules = true
      @current_user.agreed_to_email = (params['email-opt-out'] == 'on')


      extra_info = ZooniverseUserExtraInfo.new
      extra_info.first_name = params[:first_name]
      extra_info.last_name = params[:last_name]
      extra_info.address1 = params['address_1']
      extra_info.address2 = params['address_2']
      extra_info.city = params[:city]
      extra_info.state = params[:state]
      extra_info.zip_code = params[:zipcode]
      extra_info.phone_no = params[:telephone]
      extra_info.zooniverse_user = @current_user

      # binding.pry
      extra_info.save

    elsif(params['no_thanks.x'])
      @current_user.sweeps_status = 'out'
    end
    @current_user.save
    redirect_to root_path
  end
  
  def signup

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
    # binding.pry
  end

  def params_for(keys)
    values = params.values_at *keys
    Hash[ *keys.zip(values).flatten ]
  end
end
