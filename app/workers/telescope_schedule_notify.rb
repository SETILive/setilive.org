class TelescopeScheduleNotify
  include Sidekiq::Worker
  # 9 retries will span 9^4+15 seconds or 1.8 hours
  sidekiq_options :retry => 9, :timeout => 3600
  
  def perform( email_arr, time_int )
    UserMailer.schedule_notify( email_arr, time_int ).deliver
  end
  
end