# initialize_parameters.rake

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

# frank.rb
task :frank_parms_init => :environment do
	RedisConnection.set( 'frank_parms',
		{ t_accum: 93, # Waterfall data collection time
	      followup_deadline_time: 267, # Time from subject startTimeNanos to SonATA followup request receipt
	      data_key_buffer: 30, # Amount observation data life is extended to avoid races.
	      followup_lead_time: 15 # Lead time from classification to followup deadline
	    }.to_json
	  )
end