task :process_sims => :environment do
  simulations = []
  files = Dir.glob("data/et_sims/*.json")
  files.each_with_index do |file,index|

    name = file.split("/").last.split(".").first
    data =JSON.parse(IO.read(file))
    # png = make_png(data,758,410)
    # data_url  = upload_file("simulations/simulation_#{name}.json", data.to_json)
    # image_url = upload_file("simulations/simulation_#{name}.png",png.to_s)
    data_url = "http://zooniverse-seti.s3.amazonaws.com/simulations/simulation_#{name}.json"
    image_url = "http://zooniverse-seti.s3.amazonaws.com/simulations/simulation_#{name}.png"

    data.delete("data")
    
    data[:data_url]= data_url
    data[:image_url]= image_url

    simulations.push data
    puts "done #{index} of #{files.count} }"
  end
  puts simulations
  outfile = File.open("data/et_sims/upload_list.json","w")
  outfile.write(JSON.pretty_generate simulations)
end


task :add_sims_to_db => :environment do
  JSON.parse(IO.read("data/et_sims/upload_list.json")).each do |simulation|
    Simulation.create(simulation)
  end
end


def make_png(observation, img_width,img_height)
  png = ChunkyPNG::Image.new(img_width, img_height, ChunkyPNG::Color.rgba(255, 0, 0, 255))
  width  = observation['width']
  height = observation['height']
  beam =   observation['data']
  max = beam.max 
  min = beam.min
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
  bucket = s3.buckets['zooniverse-seti']
  object = bucket.objects[name]
  object.write( data, :acl=>:public_read )
  object.public_url
end
