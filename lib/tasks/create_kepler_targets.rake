task :create_kepler_targets => :environment do
  kepler_sources = JSON.parse(IO.read("data/kepler_planets_data/setiKeplerTargets.json"))

  kepler_sources.each_pair do |kepler_id, details|
    info = details['star_info']
    info["planets"]= details['planets']

    s=Source.new( :name => kepler_id, 
                :coords=> [info.delete("ra"),info.delete("dec")],
                :zooniverse_id => info.delete("zooniverse_id").gsub("SPH","SSL"),
                :type => "kepler_planet",
                :meta => info
              )

    "problem saving #{kepler_id}" unless s.save
  end
end


task :update_frank_targets => :environment do
  targets = JSON.parse(HTTParty.get('http://frank.setilive.org/targets'))
  targets.each do |target|
    name = target['target_name']
    target_id = target['target_id']

    if name.match(/KOI/)
      kio = name.match(/KOI\s\d*\.\d*/).to_s.match(/\d*\.\d*/).to_s
      puts "kio is #{kio}"
      source = Source.where("meta.planets.kio" => kio).first
      if source
        source.seti_id = target_id 
        source.save
      else
        puts "couldnt find kepler source for #{kio}"
      end
    else
      puts "have non kepler target, #{target}"
    end
  end
end
