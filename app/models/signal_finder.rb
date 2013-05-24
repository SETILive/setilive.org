class SignalFinder
  include MongoMapper::Document
  key :pending_ids, Array
  key :chains , Array
  key :tolerance, Float, :default=>1
  key :clusters_on, Array, :default=>[:ang, :mid]
  key :weights, Hash , :default => {ang: 5.73, mid: 10.0 } # ang:10 deg, mid:10%
  key :consensus_on, Array
  key :centers_in_coords, Array, :default => [:ang,:mid]
  key :user_clusters, Array

  belongs_to :observation
  
  timestamps! 
  
  before_create :load_parms
  
  def load_parms
    if ( temp = RedisConnection.get('signal_finder_parms') )
      self.weights = JSON.parse( temp )['weights']
    end
  end
  

  def self.create_with_observation(observation, args={})
    
    args = args.merge( { :observation_id=> observation.id } )
    finder = SignalFinder.create(args)
    
    # Process each classifications separately in Phase 1
    observation.subject.classifications.each do |c|
      # Collect the user's signals
      user_chains = []
      sigs = observation.subject_signals.select do |ss| 
        ss.classification_id == c.id
      end
      sigs.each do |ss|
        # Note that ang: from subject_signal.calc_angle is now limited to +/-pi/2
        user_chains << { center:{}, points: [{ang: ss.calc_angle, mid: ss.calc_mid, grad: ss.calc_grad, ss_id: ss.id}] }
      end
      i = 0
      done = true
      while i < user_chains.count
        j = i + 1
        while j < user_chains.count
          if finder.compare_chains(user_chains[i],user_chains[j])
            user_chains[i][:points] = user_chains[i][:points] | user_chains[j][:points]
            user_chains.delete_at j 
            j=j-1
            done=false 
          end 
          j += 1
        end
        i += 1
      end
      
      # Phase 1 Clustering:
      # Take each user chain cluster and convert it to a single point chain
      # from the cluster average.
      user_chains.each do |uc|
        finder.calc_center_for_chain( uc )
        # Note confidence is ignored as it's not relevant until phase 2
        
        # Add these collapsed chains to the chains array.        
        # Note that signal_id is now an array of signal_ids that
        # went into that collapsed point. When the points are combined in chains,
        # each point in the chain will have an array of signal_ids.
        finder.chains << {center:{}, confidence: 0, 
          points: [{ang: uc[:center][:ang], mid: uc[:center][:mid], 
          grad: uc[:center][:grad], 
          signal_id: uc[:points].collect { |p| p[:ss_id] } }]}
      end
    end
    puts "chains:#{finder.chains.to_json}"
    finder
  end 

  def add_signal(signal_id)
    signal = SubjectSignal.find(signal_id)
    if signal and signal.real?
      chains << {center:{}, confidence: 0, points:[{ang: signal.calc_angle, mid: signal.calc_mid , grad: signal.calc_grad, signal_id: signal.id}]}
      signal_ids.delete(signal_id)
    end
  end

  def update 
    pending_ids.each do |signal_id|
      add_signal(signal_id)
    end
    find_groups
  end
 
  def check_for_results
    until self.update_chains
    end
    self.calc_confidence
    self.centers
    self.interesting_signals
  end
  
  
  def interesting_signals 
    chains.select{|chain| chain[:confidence] > 0.7  }
  end
  
  def generate_signal_groups 
    self.check_for_results.collect do |signal|
      SignalGroup.create( angle: signal[:center][:ang], 
                          mid: signal[:center][:mid],
                          gradient: signal[:center][:grad],
                          confidence: signal[:confidence], 
                          subject_signal_ids: signal[:points].collect{|s| s[:signal_id]},
                          source: self.observation.source,
                          observation: observation )
    end
    
  end

  def calc_confidence
    total = self.observation.subject.live_classification_count
    chains.each do |c|
      c[:confidence] = c[:points].count.to_f / total 
    end
  end

  def dist(point1,point2)
    val =0
    self.clusters_on.each do |key|
      raw_dist = (point1[key] - point2[key]).abs
      val = val + ( raw_dist  * weights[key] )**2 
    end
    val =Math.sqrt(val)
  end


  def calc_center_for_chain(chain)
        
    num_points_in_chain = chain[:points].count.to_f
    self.centers_in_coords.each do |key|
      ave = 0.0
      chain[:points].each do |point|
        ave += point[key]
      end
      chain[:center][key] = ave / num_points_in_chain
    end
    chain[:center][:grad] = Math.tan(chain[:center][:ang])
  end
  
  def centers
    chains.each do |chain|
      self.calc_center_for_chain chain
    end
  end

  def update_chains
      # opts=arg_hash.extract_options! 
      i=0
      done = true
      
      while i < chains.count do 
        j=i+1
        while j<chains.count do
        if compare_chains(chains[i],chains[j])
          chains[i][:points] = chains[i][:points] | chains[j][:points]
          chains.delete_at j 
          j=j-1
          done=false 
        end 
        j=j+1
      end
      i=i+1
    end
    
    done 
  end
  
  def find_groups
    if pending_ids.empty?
      chains
    else
      
      pending_ids.each {|id| add_signal id }

      while !self.update_chains
      end
      chains 
    end
  end

  def compare_chains(chain1, chain2)
    chain1[:points].each do |part1|
      chain2[:points].each do |part2|
        if self.dist(part1, part2) < tolerance
          return true 
        end
      end
    end
    return false
  end
  
end
