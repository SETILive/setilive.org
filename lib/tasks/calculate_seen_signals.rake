task :calculate_seen_signals => :environment do
  puts "HERE "
  total = ZooniverseUser.count
  index =0 
  ZooniverseUser.find_each do |z|
    index += 1
    z.recalculate_signal_stats
    puts "done #{index} of #{total}"
  end
end