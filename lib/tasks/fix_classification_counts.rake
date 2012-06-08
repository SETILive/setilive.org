task :fix_classification_counts => :environment do
	total = Subject.count
	puts "fixing the classification counts on #{total} subjects"
	done =0 
  Subject.find_each do |subject|
	  done += 1
		puts "have done #{done} of #{total}"
		subject.set(:classification_count => subject.classifications.count)
	end
end