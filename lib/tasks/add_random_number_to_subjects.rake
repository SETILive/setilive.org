task :add_random_number_to_subjects => :environment do
  Subject.find_each{ |s| s.set :random_number => rand }
end
