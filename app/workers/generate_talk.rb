class GenerateTalk
  include Sidekiq::Worker 

  def perform(subject_id)
    subject = Subject.find(subject_id)
    if subject
      observations =[]
      subject.observations.each do |observation|
        observations<< { 
                         zooniverse_id: observation.zooniverse_id,
                         location: "https://zooniverse-seti.s3.amazonaws.com/images/observation_#{observation.zooniverse_id}.png",
                         thumbnail_location: "https://zooniverse-seti.s3.amazonaws.com/thumbs/observation_#{observation.zooniverse_id}.png",
                         size: [observation.width, observation.height],
                         target: { zooniverse_id: observation.source.zooniverse_id }
                       } 
      end
      post = {  zooniverse_id:subject.zooniverse_id, observations: observations}
      puts JSON.pretty_generate post

      TalkCreator.talk_create(post)
    else
      throw 'Subject could not be uploaded to talk #{subject_id}'
    end
  end

end