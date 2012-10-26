class SignalFinder
  include MongoMapper::Document
  key :pending_ids, Array
  key :chains , Array
  key :tolerance, Float, :default=>1
  key :clusters_on, Array, :default=>[:ang, :mid]
  key :weights, Hash , :default => {ang: (1.0/20.0), mid: (1.0/5.0) }
  key :consensus_on, Array
  key :centers_in_coords, Array, :default => [:ang,:mid]
  key :limits, Hash, :default => {:ang=>180}

  belongs_to :observation
  
  timestamps! 


  def self.create_with_observation(observation, args={})
    args = args.merge( { :observation_id=> observation.id, :pending_ids => observation.subject_signals.collect(&:_id)})
    finder = SignalFinder.create(args)
    finder
  end 

  def add_signal(signal_id)
    signal = SubjectSignal.find(signal_id)
    if signal and signal.real?
      chains << {center:{}, confidence: 0, points:[{ang: signal.angle, mid: signal.calc_mid , grad: signal.grad, signal_id: signal.id}]}
    end
  end

  def update 
    pending_ids.each do |signal_id|
      add_signal(signal_id)
    end
    find_groups
  end
 
  def check_for_results
    self.find_groups
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
                          confidence: signal[:confidence], 
                          subject_signal_ids: signal[:points].collect{|s| s[:signal_id]},
                          source: self.observation.source,
                          observation: observation )
    end
    
  end

  def calc_confidence
    total = self.observation.subject.classification_count
    chains.each do |c|
      c[:confidence] = c[:points].count.to_f / total 
    end
  end

  def dist(point1,point2)
    val =0

    self.clusters_on ||= chains.first.points.first.keys
     
    self.clusters_on.each{ |key| weights[key] ||= 1} #fill in missing weights
    
    self.clusters_on.each do |key|
      raw_dist = (point1[key] - point2[key]).abs
      if limits[key]
        if raw_dist > limits[key] 
          raw_dist = raw_dist - limits[key] 
        end
      end
        val = val + ( raw_dist  * weights[key] )**2 
    end
    val =Math.sqrt(val)
  end


  def calc_center_for_chain(chain)
    if self.centers_in_coords.length==0
      self.centers_in_coords = chains.first[:points].first.keys
    end

    ave = self.centers_in_coords.each.inject({}){|r,v| r[v] = 0.0;r }
    chain[:points].each do |point|
      self.centers_in_coords.each{|key| ave[key]+=point[key] }
    end
    
    no_points_in_chain = chain[:points].count.to_f
    chain[:center] = ave.keys.inject({}){|r,key| r[key]= ave[key]/no_points_in_chain; r}
    
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
    joined = false
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
