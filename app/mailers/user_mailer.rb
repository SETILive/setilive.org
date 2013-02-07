class UserMailer < ActionMailer::Base
  default from: "noreply@zooniverse.org"
  
  def schedule_notify( emails, t_next_int )
    tz_pt = "Pacific Time (US & Canada)"
    tz_et = "Eastern Time (US & Canada)"
    tz_uk = "Europe/London"
    utc_time = Time.at( t_next_int ).utc
    @utc_str =  utc_time.ctime + ' UTC'
    @uk_str = get_time_string( utc_time, tz_uk )
    @et_str = get_time_string( utc_time, tz_et )
    @pt_str = get_time_string( utc_time, tz_pt )
    @url_setilive = 'http://setilive.org'
    @url_setiquestinfo = 'http://setiquest.info'
    subject = "SETILive's Next Scheduled Live Session"
    mail(:bcc => emails, :subject => subject)    
  end
  
  def get_time_string( utc_time, tz_str )
    str=''
    utc_time.in_time_zone(tz_str).ctime.split[0..3].each {|x| str += (x + ' ') }; str + tz_str
  end
  
end
