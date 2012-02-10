task :generate_badges => :environment do
  Badge.delete_all
  badges = JSON.parse(IO.read('data/badges.json'))

  badges['badges'].each do |badge|
    badge['condition'] = CoffeeScript.compile "return #{badge['condition']}"
    Badge.create badge
  end
end