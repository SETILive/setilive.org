class TelescopeScheduleNotify
  include Sidekiq::Worker
  sidekiq_options :retry => true, :timeout => 3600
  
  def perform( email_arr, time_int )
    UserMailer.schedule_notify( email_arr, time_int ).deliver
  end
  
end