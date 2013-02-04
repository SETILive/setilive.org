# Use only if no workflow data, i.e., initialize a new database
task :load_workflow => :environment do
  puts "loading archive data workflow "
  data = JSON.parse(IO.read("data/workflow2.json"))
  workflow = Workflow.new data
  workflow.save
  puts "loading live data workflow"
  data = JSON.parse(IO.read("data/workflow3.json"))
  workflow = Workflow.new data
  workflow.save
end


task :update_workflow => :environment do
  puts "updating workflows"
  data = JSON.parse(IO.read(Rails.root.join('data', 'workflow2.json')))
  workflow = Workflow.where(:name => 'zooniverse_interface2').first
  if workflow
    puts "archive workflow already exists. Updating..."
    workflow.questions = data['questions']
  else
    puts "archive workflow doesn't exist. Adding..."
    workflow = Workflow.new data
  end
  workflow.save
  
  puts "updating live data workflow"
  data = JSON.parse(IO.read(Rails.root.join('data', 'workflow3.json')))
  workflow = Workflow.where(:name => 'zooniverse_interface3').first
  if workflow
    puts "live data workflow already exists. Updating..."
    workflow.questions = data['questions']
  else
    puts "live data workflow doesn't exist. Adding..."
    workflow = Workflow.new data
  end
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
  Rake::Task['initialize_parameters'].execute
end