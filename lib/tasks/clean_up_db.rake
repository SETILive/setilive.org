task :clean_up_db => :environment do
  total = Subject.count
  count = 0
  delete_count = 0
  Subject.find_each do |s|
    count += 1
    puts "have done #{count} of #{total} deleted #{delete_count}"
    if s.observations.count == 0
      delete_count+=1
      s.destroy
    end
  end
end