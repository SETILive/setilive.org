def drop_indexes_on(model)
  model.collection.drop_indexes if model.count > 0
end

desc "Creates indexes on collections"
task :ensure_indexes => :environment do
  puts "Building indexes for Badge"
  drop_indexes_on(Badge)
  Badge.ensure_index [['level', 1]]
  
  puts "Building indexes for Classification"
  drop_indexes_on(Classification)
  Classification.ensure_index [['created_at', -1]]
  Classification.ensure_index [['zooniverse_user_id', 1]]
  Classification.ensure_index [['subject_id', 1]]
  
  puts "Building indexes for Observation"
  drop_indexes_on(Observation)
  Observation.ensure_index [['zooniverse_id', 1]]
  Observation.ensure_index [['source_id', 1]]
  Observation.ensure_index [['subject_id', 1]]
  Observation.ensure_index [['uploaded', 1], ['subject_id', 1]]
  
  puts "Building indexes for Source"
  drop_indexes_on(Source)
  Source.ensure_index [['zooniverse_id', 1]]
  Source.ensure_index [['seti_ids', 1]]
  
  puts "Building indexes for Subject"
  drop_indexes_on(Subject)
  Subject.ensure_index [['zooniverse_id', 1]]
  Subject.ensure_index [['random_number', 1]]
  Subject.ensure_index [['activity_id', 1]]
  Subject.ensure_index [['status', 1]]
  
  puts "Building indexes for SubjectSignal"
  drop_indexes_on(SubjectSignal)
  SubjectSignal.ensure_index [['classification_id', 1]]
  
  # None yet
  # puts "Building indexes for Workflow"
  # drop_indexes_on(Workflow)
  # Workflow.ensure_index
  
  puts "Building indexes for ZooniverseUser"
  drop_indexes_on(ZooniverseUser)
  ZooniverseUser.ensure_index [['zooniverse_user_id', 1]]
  ZooniverseUser.ensure_index [['favourite_ids', 1]]
  
  puts "Building indexes for ZooniverseUserExtraInfo"
  drop_indexes_on(ZooniverseUserExtraInfo)
  ZooniverseUserExtraInfo.ensure_index [['zooniverse_user_id', 1]]
end
