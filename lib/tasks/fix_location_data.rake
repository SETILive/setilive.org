task :fix_location_data => :environment do
 
  Subject.find_each do |s|
    ["pol", "sub_channel", "observation_id", "original_redis_key"].each do |key|
      if s.location[key]
        s[key]= s.location.delete(key)
      end
      s.start_time = s.location["time"]
      s.central_freq = s.location["freq"]
      s.save
    end
  end
end