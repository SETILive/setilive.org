require 'chunky_png'

if Rails.env.development?
  # Configure for 
  # https://github.com/jubos/fake-s3 (Ruby)
  # or
  # https://github.com/jserver/mock-s3 (Python)
  # Haven't made either of these work yet.
  AWS.config :access_key_id=>'123', :secret_access_key => 'abc', 
    :use_ssl => false, :s3_port => 10001, :s3_endpoint => 'localhost'
else
  AWS.config :access_key_id=>'***REMOVED***', :secret_access_key => '***REMOVED***'
end

class ObservationUploader
  include Sidekiq::Worker 

  def perform(observation_id)
    @observation  = Observation.find(observation_id)
    @data = @observation.get_data
    puts "observation uploaded ? "
    puts @observation.uploaded 
    if @observation.uploaded 
      return false
    end
    @path_to_data    = upload_to_s3
    @image_urls      = generate_images  

    if @observation.has_simulation
      @simulation_urls = generate_simulations 
    end

    update_observation

    
    unless @observation.subject.observations.collect{|o| o.uploaded}.include?(false)
      puts "Talk objects not generated on dev server"
      #GenerateTalk.new.perform @observation.subject.id unless Rails.env.development?
    end

  end

  def update_observation
    @observation.data_url       = @path_to_data
    @observation.image_url      = @image_urls[:image]
    @observation.thumb_url      = @image_urls[:thumb]

    if @observation.has_simulation
      @observation.simulation_url = @simulation_urls[:image]
      @observation.simulation_thumb_url = @simulation_urls[:thumb]
      @observation.simulation_reveal_url = @simulation_urls[:reveal]
    end

    @observation.uploaded=true
    RedisConnection.del @observation.data_key
    @observation.save
  end

  def upload_to_s3
    data = @data
    upload_file("data/observation_#{@observation.zooniverse_id}.jsonp", "observation(#{data});")
  end

  def upload_file(name , data)
    if Rails.env.development?
      #Kluge to avoid sending data to S3 in dev mode if live data is emulated.
      # Need folders already created in ~/s3store/zooniverse-seti/
      # images, thumbs, data
      # Run local HTTP file server in s3store on port 9914
      # (i.e. python -m SimpleHTTPServer 9914) 
      bucket_home = ENV['HOME'] + '/' + 's3store'
      bucket_name = 'zooniverse-seti-dev'
      file_path = bucket_home + '/' + bucket_name + '/' + name
      object_file = File.open( file_path, 'w' )
      object_file.write( data )
      object_file.close
      'http://localhost:9914/' + bucket_name + "/" + name
    else
      s3 = AWS::S3.new
      bucket = s3.buckets['zooniverse-seti-dev']
      object = bucket.objects[name]
      object.write( data, :acl=>:public_read )
      object.public_url
    end
  end

  def rename_file(url, zoo_name)
    if Rails.env.development?
      #Kluge to avoid sending data to S3 in dev mode if live data is emulated.
      # Need folders already created in ~/s3store/zooniverse-seti/
      # images, thumbs, data
      # Run local HTTP file server in s3store on port 9914
      # (i.e. python -m SimpleHTTPServer 9914) 
      bucket_home = ENV['HOME'] + '/' + 's3store'
      bucket_name = 'zooniverse-seti-dev'
      temp = url.split("/")
      name_1 = temp[3] + "/" + temp[4]
      file_path_1 = bucket_home + '/' + bucket_name + '/' + name_1
      name_2 = temp[temp.length-2] + "/observation_" + 
                zoo_name + '.' + temp.last.split('.').last
      file_path_2 = bucket_home + '/' + bucket_name + '/' + name_2
      return nil unless File.exists?(file_path_1)
      File.rename(file_path_1, file_path_2)
      if File.exists?(file_path_2) 
        'http://localhost:9914/' + bucket_name + "/" + name_2
      else
        nil
      end
    else
      s3 = AWS::S3.new
      bucket = s3.buckets['zooniverse-seti-dev']
      temp = url.split("/")
      name_1 = temp[4] + "/" + temp[5]
      object = bucket.objects[name_1]
      return nil unless object.exists?
      name_2 = temp[temp.length-2] + "/observation_" + 
                zoo_name + '.' + temp.last.split('.').last
      object.rename_to(name_2, :acl=>:public_read)
      object = bucket.objects[name_2]
      object.exists? ? object.public_url.to_s : nil
    end
  end

  def generate_simulations
    img_width  = 758
    img_height = 410

    puts "generating simulation"

    thumb_image_width = 100
    thumb_image_height = 54 
    
    data = @observation.get_data
    simulation_data = @observation.simulations.first.data

    make_sim_reveal_png = make_sim_reveal_png(data, simulation_data, @observation, img_width,img_height )

    data = data.map.with_index{|v,i| v+simulation_data['data'][i]}

    main_image  = make_png(data, @observation, img_width,img_height)
    thumb_image = make_png(data, @observation, thumb_image_width,thumb_image_height)
    image_url = upload_file("images/observation_s_#{@observation.zooniverse_id}_#{@observation.simulations.first.id}.png",main_image.to_s)
    reveal_url = upload_file("images/observation_sr_#{@observation.zooniverse_id}_#{@observation.simulations.first.id}.png", make_sim_reveal_png.to_s)
    thumb_url = upload_file("thumbs/observation_s_#{@observation.zooniverse_id}_#{@observation.simulations.first.id}.png",thumb_image.to_s)
    {image: image_url, thumb: thumb_url, reveal: reveal_url}
  end 

  def generate_images
    img_width  = 758
    img_height = 410

    thumb_image_width = 100
    thumb_image_height = 54

    data = @data
    main_image  = make_png(data, @observation, img_width,img_height)
    thumb_image = make_png(data, @observation, thumb_image_width,thumb_image_height)
    
    image_url = upload_file("images/observation_#{@observation.zooniverse_id}.png",main_image.to_s)
    thumb_url = upload_file("thumbs/observation_#{@observation.zooniverse_id}.png",thumb_image.to_s)
    {image: image_url, thumb: thumb_url}
  end 


  def make_sim_reveal_png(data, sim_data, observation, img_width,img_height)
    png = ChunkyPNG::Image.new(img_width, img_height, ChunkyPNG::Color.rgba(255, 0, 0, 255))
    width  = observation.width
    height = observation.height

    beam = data
    max = 255 # beam.max 
    min = 0  #beam.min
    
    (0..(img_width-1)).each do |xpos|
      (0..(img_height-1)).each do |ypos|
        x= xpos*width/img_width
        y= ypos*height/img_height
        pos = x + width*y
        val = (beam[pos]- min) * 255 / (max-min)
        
        if( sim_data['data'][pos] > 0 )
          png[xpos,ypos] = ChunkyPNG::Color.rgba(255, 0, 0, 255)
        else
          png[xpos,ypos] = ChunkyPNG::Color.rgba(val +sim_data['data'][pos], val, val, 255)
        end

      end
    end    
    png
  end


  def make_sim_reveal_png(data, sim_data, observation, img_width,img_height)
    png = ChunkyPNG::Image.new(img_width, img_height, ChunkyPNG::Color.rgba(255, 0, 0, 255))
    width  = observation.width
    height = observation.height

    beam = data
    max = beam.max 
    min = beam.min
    
    (0..(img_width-1)).each do |xpos|
      (0..(img_height-1)).each do |ypos|
        x= xpos*width/img_width
        y= ypos*height/img_height
        pos = x + width*y
        val = (beam[pos]- min) * 255 / (max-min)
        
        if( sim_data['data'][pos] > 0 )
          png[xpos,ypos] = ChunkyPNG::Color.rgba(255, 0, 0, 255)
        else
          png[xpos,ypos] = ChunkyPNG::Color.rgba(val +sim_data['data'][pos], val, val, 255)
        end

      end
    end    
    png
  end

  def make_png(data, observation, img_width,img_height)
    png = ChunkyPNG::Image.new(img_width, img_height, ChunkyPNG::Color.rgba(255, 0, 0, 255))
    width  = observation.width
    height = observation.height

    beam = data
    max = beam.max 
    min = beam.min
    (0..(img_width-1)).each do |xpos|
      (0..(img_height-1)).each do |ypos|
        x= xpos*width/img_width
        y= ypos*height/img_height
        pos = x + width*y
        val = (beam[pos]- min) * 255 / (max-min)
        png[xpos,ypos] = ChunkyPNG::Color.rgba(val, val, val, 255)
      end
    end    
    png
  end

end