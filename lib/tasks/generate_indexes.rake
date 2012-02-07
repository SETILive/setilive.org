task :generate_indexes => :environment do
	Subject.ensure_index [ location => "2d"  ]

end