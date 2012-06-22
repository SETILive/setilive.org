require 'chunky_png'
AWS.config :access_key_id=>'***REMOVED***', :secret_access_key => '***REMOVED***'



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
      GenerateTalk.new.perform s.id
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
    s3 = AWS::S3.new
    bucket = s3.buckets['zooniverse-seti']
    object = bucket.objects[name]
    object.write( data, :acl=>:public_read )
    object.public_url
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