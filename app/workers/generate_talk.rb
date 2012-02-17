class GenerateTalk
  include Sidekiq::Worker 
  
  def perform(subject_id)
    subject = Subject.find(subject_id)
    if subject
      observations =[]
      subject.observations.each do |observation|
        observations<< { zooniverse_id: observation.zooniverse_id,
                            location: "https://zooniverse-seti.s3.amazonaws.com/images/observation_#{observation.zooniverse_id}.png",
                            thumbnail_location: "https://zooniverse-seti.s3.amazonaws.com/thumbs/observation_#{observation.zooniverse_id}.png",
                            size: [observation.width, observation.height],
                            target: { zooniverse_id: observation.source.zooniverse_id }
                          } 
      end
      post = { zooniverse_id: subject.zooniverse_id,  observation_group: observations}
      puts JSON.pretty_generate post
      puts HTTParty.post('https://talk.setilive.org/observation_groups', post.merge({format: 'json', username:'***REMOVED***', password: '***REMOVED***'}))

    else
      throw 'Subject could not be uploaded to talk #{subject_id}'
    end
  end

end