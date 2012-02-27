task :generate_subjects => :environment do
  Dir.glob("data/bson-pairs-set1/*.bson").each do |file|
    puts "doing #{file}"
    subject = BSON.deserialize(IO.read(file))
    key = "subject_0_1_1_123"
    s=Subject.generate_subject_from_frank(subject, key)
    s.save
  end

  Observation.all.each{|o| o.processNow}
end