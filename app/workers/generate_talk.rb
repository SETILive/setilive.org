class GenerateTalk
  include Sidekiq::Worker 

  def perform(subject_id)
    subject = Subject.find(subject_id)
    if subject
      observations =[]
      has_simulation = false 

      subject.observations.each do |observation|
        
        if observation.has_simulation 
          has_simulation = true 
          location = observation.simulation_url
          thumb_location = observation.simulation_thumb_url
        else
          location = observation.image_url
          thumb_location = observation.thumb_url
        end



        observations<< { 
                         zooniverse_id: observation.zooniverse_id,
                         location: location,
                         thumbnail_location: thumb_location,
                         size: [observation.width, observation.height],
                         target: { zooniverse_id: observation.source.zooniverse_id },
                         simulation:  observation.has_simulation,
                       } 
      end
      post = {  zooniverse_id:subject.zooniverse_id, observations: observations, simulation: has_simulation}
      # puts JSON.pretty_generate post

      TalkCreator.talk_create(post)
    else
      throw 'Subject could not be uploaded to talk #{subject_id}'
    end
  end

end