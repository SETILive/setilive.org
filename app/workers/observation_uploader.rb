require 'chunky_png'
AWS.config :access_key_id=>'***REMOVED***', :secret_access_key => '***REMOVED***'


class ObservationUploader
  include Sidekiq::Worker 


  def perform(observation_id)
    # puts "uploading observation #{observation_id}"
    @observation  = Observation.find(observation_id)
    
    if @observation.uploaded 
      # puts "Observation already uploaded nothing to be done"
      return false
    end
    @path_to_data = upload_to_s3
    # puts 'generating images'
    @image_urls = generate_images
    # puts 'updating observation'
    update_observation
    # puts 'done'
  end

  def update_observation
    @observation.data_url  = @path_to_data
    @observation.image_url = @image_urls[:image]
    @observation.thumb_url = @image_urls[:thumb]
    @observation.data=[]
    @observation.uploaded=true
    @observation.save
  end

  def upload_to_s3

    upload_file("data/observation_#{@observation.zooniverse_id}.jsonp", "observation(#{@observation.data.to_json});")
  
  end

  def upload_file(name , data)
    s3 = AWS::S3.new
    bucket = s3.buckets['zooniverse-seti']
    object = bucket.objects[name]
    object.write( data, :acl=>:public_read )
    object.public_url
  end

  def generate_images
    img_width  = 758
    img_height = 410

    thumb_image_width = 100
    thumb_image_height = 54
    
    main_image  = make_png(@observation, img_width,img_height)
    thumb_image = make_png(@observation, thumb_image_width,thumb_image_height)
    
    image_url = upload_file("images/observation_#{@observation.zooniverse_id}.png",main_image.to_s)
    thumb_url = upload_file("thumbs/observation_#{@observation.zooniverse_id}.png",thumb_image.to_s)
    {image: image_url, thumb: thumb_url}
  end 

  def make_png(observation, img_width,img_height)
    png = ChunkyPNG::Image.new(img_width, img_height, ChunkyPNG::Color.rgba(255, 0, 0, 255))
    width  = observation.width
    height = observation.height
    beam = observation.data

    (0..(img_width-1)).each do |xpos|
      (0..(img_height-1)).each do |ypos|
        x= xpos*width/img_width
        y= ypos*height/img_height
        pos = x + width*y
        val = beam[pos]
        png[xpos,ypos] = ChunkyPNG::Color.rgba(val, val, val, 255)
      end
    end    
    png
  end

end