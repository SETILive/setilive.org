class SignalFinder
  include MongoMapper::Document
  key :pending_ids, Array
  key :chains , Array
  key :tolerance, Float, :default=>1
  key :clusters_on, Array, :default=>[:ang, :mid]
  key :weights, Hash , :default => {ang: (1.0/20.0), mid: (1.0/5.0) }
  key :consensus_on, Array
  key :centers_in_coords, Array, :default => [:inter,:grad]
  key :limits, Hash, :default => {:ang=>180}

  belongs_to :observation

  def self.create_with_observation(observation, args={})
    args = args.merge( { :observation_id=> observation.id, :pending_ids => observation.subject_signals.collect(&:_id)})
    finder = SignalFinder.create(args)
    finder
  end 

  def add_signal(signal_id)
    signal = SubjectSignal.find(signal_id)
    if signal and signal.real?
      chains << [{ang: signal.angle, mid: signal.calcMid , grad: signal.grad, subject_id: signal.id}]
    end
  end

  def update 
    pending_ids.each do |signal_id|
      add_signal(signal_id)
    end
    find_groups
  end
 
  def check_for_results
    chains.each do |chain|
      if chain.confidence > 0.1
        puts chain.to_json
        # generate_signal_group(chain)
      end
    end
  end

  def dist(point1,point2)
    val =0


    # if clusters_on.nil? || clusters_on.count == 0
    #   puts "HERE!!!!!!! #{chains.first.first.keys}"
      clusters_on ||= chains.first.first.keys
    # end
 

    clusters_on.each{ |key| weights[key] ||= 1} #fill in missing weights
    
    clusters_on.each do |key|
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

  def centers
    if centers_in_coords.length==0
      coords = chains.first.first.keys
    end

    centers=[]
    chains.each do |chain| 
      ave = coords.each.inject({}){|r,v| r[v] = 0.0;r }
      chain.each do |point|
        coords.each{|key| ave[key]+=point[key] }
      end
      no_points_in_chain = chain.count.to_f
      centers<<ave.keys.inject({}){|r,key| r[key]= ave[key]/no_points_in_chain; r}
    end
    centers
  end

  def update_chains
      # opts=arg_hash.extract_options! 
      i=0
      done = true
      
      while i < chains.size do 
        j=i+1
        while j<chains.size do
        if compare_chains(chains[i],chains[j])
          chains[i] = chains[i] | chains[j]
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
  
  def find_groups()
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
    chain1.each do |part1|
      chain2.each do |part2|
        if self.dist(part1, part2) < tolerance
          return true 
        end
      end
    end
    return false
  end
  

  def consensus
    
    results=[];
    
    with_feedback= tr 
    
    if consensus_on.count==0
      consensus_on = self.chains.first.first.keys
    end
    
    chains.each do |chain|
      counts = consensus_on.inject({}){|r,key| r[key] = {} ; r}
      chain.each do |point|
        consensus_on.each do |key|
          counts[key][point[key]] ||=0
          counts[key][point[key]]+=1
        end
      end
      if with_feedback
        result = consensus_on.inject({}) do |r,key| 
          val= counts[key].invert.max[1]
          total = counts[key].values.sum.to_f
          r[key]={ :value => val, :confidence=>counts[key][val].to_f/total}
          r 
        end
      else 
        result = consensus_on.inject({}){|r,key| r[key]=counts[key].invert.max[1]; r }
      end
      results << result
    end
    results
  end

end
