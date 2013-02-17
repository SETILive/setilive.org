# rake schedule_info_check <RAILS_ENV=production>
# ctl-c to quit and close log file
task :schedule_info_check => :environment do
  f = File.open('schedule_info_log.txt', 'a')
  f.puts( "=================")
  f.puts( "current_status, next_status_change., status_change_inactive")
  prev = 'initialize'
  while true
    current = RedisConnection.get('current_status')
    current = '  ' + current if current == 'active'
    change = Time.at( RedisConnection.get('next_status_change').to_i / 1000 )
    change_inactive = RedisConnection.get('status_change_inactive') 
    current = "#{current}, #{change}, #{change_inactive ? 'true' : 'false' }"
    if current != prev
      puts Time.now.to_s + ": " + current
      f.puts Time.now.to_s + ": " + current
      prev = current
    end
    sleep(1)
  end
end
