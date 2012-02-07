task :create_kepler_targets => :environment do
  kepler_sources = JSON.parse(IO.read("tmp/kepler_planets_data/setiKeplerTargets.json"))

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