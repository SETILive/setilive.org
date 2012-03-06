task :generate_badges => :environment do

  badges = JSON.parse(IO.read('data/badges.json'))

  badges['badges'].each do |badge|
    badge['condition'] = CoffeeScript.compile "return #{badge['condition']}"
    oldBadge = Badge.find_by_title badge['title']
    if oldBadge
      oldBadge.update_attributes badge 
      puts "upadating badge"
    else 
      puts "creating new badge"
      Badge.create badge
    end
  end

  Rails.cache.delete("all_badges")
end