
task :load_workflow => :environment do
  Workflow.delete_all
  data = JSON.parse(IO.read("data/workflow.json"))
  workflow = Workflow.new data
  workflow.save
end
