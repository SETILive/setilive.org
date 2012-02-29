task :load_workflow => :environment do
  Workflow.delete_all
  data = JSON.parse(IO.read("data/workflow.json"))
  workflow = Workflow.new data
  workflow.save
end


task :update_workflow => :environment do
  data = JSON.parse(IO.read("data/workflow.json"))
  workflow = Workflow.first
  workflow.questions = data['questions']
  workflow.save
end


task :boot_app => :environment do
  BOOTSTRAP = true
  Rake::Task['load_workflow'].execute
  Rake::Task['generate_badges'].execute
  Rake::Task['create_tutorial_subject'].execute
  Rake::Task['ensure_indexes'].execute
  Rake::Task['create_kepler_targets'].execute
  Rake::Task['generate_subjects'].execute
end