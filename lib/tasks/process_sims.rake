task :process_sims => :environment do
  simulations = []
  files = Dir.glob("setilive_sims_v1/*.json")
  files.each_with_index do |file,index|

    name = file.split("/").last.split(".").first
    data =JSON.parse(IO.read(file))
    png = make_png(data,758,410)
    data_url  = upload_file("simulations/simulation_#{name}.json", data.to_json)
    image_url = upload_file("simulations/simulation_#{name}.png", png.to_s)
    # data_url = "http://zooniverse-seti-dev.s3.amazonaws.com/development/simulations/simulation_#{name}.json"
    # image_url = "http://zooniverse-seti-dev.s3.amazonaws.com/development/simulations/simulation_#{name}.png"

    data.delete("data")

    data[:data_url]= data_url.to_s
    data[:image_url]= image_url.to_s

    simulations.push data
    puts "done #{index} of #{files.count} }"
  end
  puts simulations
  outfile = File.open("sim_upload_list.json ","w")
  outfile.write(JSON.pretty_generate simulations)
end


task :add_sims_to_db => :environment do
  JSON.parse(IO.read("sim_upload_list.json")).each do |simulation|
    Simulation.create(simulation)
  end
end


# task :make_sim_subjects => :environment do
#   sims=[]
#   Simulation.find_each |sim|
#     s=Subject.random().first.generate_simulation sim
#     sims<< s.as_json
#   end
#   File.open("simlist.json","w"){|f| f.puts JSON.pretty_generate(sims)}
# end


def make_png(observation, img_width,img_height)
  png = ChunkyPNG::Image.new(img_width, img_height, ChunkyPNG::Color.rgba(255, 0, 0, 255))
  width  = observation['width']
  height = observation['height']
  beam =   observation['data']
  max = 0
  min = 
  (0..(img_width-1)).each do |xpos|
    (0..(img_height-1)).each do |ypos|
      x= xpos*width/img_width
      y= ypos*height/img_height
      pos = x + width*y
      val = beam[pos] #(beam[pos]- min) * 255 / (max-min)
      png[xpos,ypos] = ChunkyPNG::Color.rgba(val, val, val, 255)
    end
  end    
  png
end

def upload_file(name , data)
  s3 = AWS::S3.new
  bucket = s3.buckets['zooniverse-seti-dev']
  object = bucket.objects[name]
  object.write( data, :acl=>:public_read )
  object.public_url
end
