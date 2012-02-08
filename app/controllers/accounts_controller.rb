class AccountsController < ApplicationController
  def login
    @cas_client = CASClient::Frameworks::Rails::Filter.client
    @return_to = params[:return_to] || root_url
    @small_star_field = true  
  end
  
  def logout
    @current_user = @current_zooniverse_user = nil
    session.clear
    cas_logout
  end
  
  def signup
    unless params[:password] == params[:password_confirmation]
      @messages << "Password and password confirmation don't match"
      return
    end

    create_zooniverse_user

    if @successful && params[:return_to]
      redirect_to params[:return_to]
    elsif @successful
      redirect_to root_path
    else
      flash.now[:error] = @message
      @cas_client = CASClient::Frameworks::Rails::Filter.client
      render :login
    end
  end
  
  def create_zooniverse_user
    params['name'] = "#{ params['firstname'] } #{ params['lastname'] }"
    hash = params_for %w(login email name password password_confirmation)
    result = Zooniverse.create_user(hash)
    @successful[:zooniverse] = result['success']
    @messages += result['messages'] if result['messages']
    
    if @successful[:zooniverse]
      session[:cas_extra_attributes] = { 'id' => result['user']['id'] }
      session[:zooniverse_user] = result['user']['login']
      current_zooniverse_user
    end
  end
end
