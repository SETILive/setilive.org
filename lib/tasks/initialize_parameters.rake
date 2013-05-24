# initialize_parameters.rake

# signal_finder.rb
task :signal_finder_parms_init => :environment do
  
	RedisConnection.set( 'signal_finder_parms',
    { weights: {ang: 6.37, mid: 10.0 } # 10% of max distance
        }.to_json
   )

end

# signal_group.rb
task :signal_group_parms_init => :environment do

	RedisConnection.set( 'signal_group_parms',
    { drift_max: 2.0, # Hz/sec/GHz Max Doppler
          drift_min: 0.007, # Vertical criterion
          drift_tol: 1.0, # Inter-beam matching, drift
          mid_tol: 0.05 # Inter-beam matching, normalized x
        }.to_json
   )
end

task :subject_parms_init => :environment do
  
  # Frank parameters
  followup_deadline_time = 267
  followup_lead_time = 15
  t_accum = 93
	RedisConnection.set( 'frank_parms',
		{ t_accum: t_accum, # Waterfall data collection time
	      followup_deadline_time: followup_deadline_time, # Time from subject 
              # startTimeNanos to SonATA followup request receipt
	      data_key_buffer: 30, # Observation data life extension to avoid races.
	      followup_lead_time: followup_lead_time # Lead time from classification 
              # to followup deadline
	    }.to_json
	  )

# subject.rb adaptive classification threshold parameters
# Assume t sec per beam, T second followup window, M subjects, P beams,
# Thr retirement threshold
# N users can classify  N * ( T / ( P * t ) ) subjects
# and retire            N * ( T / ( P * t ) ) / Thr subjects
# To retire M subjects, N * ( T / ( P * t ) ) / Thr = M
#                       Thr = N * ( T / ( P * t ) ) / M
# Fixed: M, t, T:       Thr = ( N / P ) * T / ( t * M ) = ( N / P ) * Fthr
# Where:                Fthr = T / t / M
#
  user_online_timeout = 2.minutes # Timer for user activity for online count in minutes
  max_archive_classifications = 19 # Archive retire threshold
  min_live_threshold = 4 # Minimum users for followup
  subjects_per_activity = 12
  number_of_beams = 2; # Default value. Posted to Frank before each session.
  user_sec_per_beam = 15 # Time per waterfall under live marking rules
  followup_window = followup_deadline_time - followup_lead_time - t_accum
  
  live_threshold_factor = 
    1.0 * followup_window / user_sec_per_beam / subjects_per_activity
  RedisConnection.set( 'live_classification_parms',
    { min_live_threshold: min_live_threshold,
      number_of_beams: number_of_beams,
      live_threshold_factor: live_threshold_factor
    }.to_json )
  RedisConnection.del('min_live_threshold')
  RedisConnection.del('number_of_beams')
  RedisConnection.del('live_threshold_factor')
  
  # Needs to be separate key - accessed in a different model method
  RedisConnection.set( 
    'max_archive_classifications', max_archive_classifications )
  

# Classification stats related items  
  RedisConnection.set( 'user_online_timeout', user_online_timeout )
  
end

# Telescope schedule email notifier parameters
task :telescope_notify_parms_init => :environment do
  RedisConnection.set( 'telescope_notify_parms', 
    { chunk_size: 200, # Number of emails sent at one time
      time_between: 15 # How often to send email chunks in minutes
      }.to_json )
end

# Initialize all parameters
task :initialize_parameters => :environment do
  Rake::Task['signal_group_parms_init'].execute
  Rake::Task['telescope_notify_parms_init'].execute
  Rake::Task['subject_parms_init'].execute
  Rake::Task['signal_finder_parms_init'].execute
end