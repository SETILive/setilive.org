class SubjectUploader
  include Sidekiq::Worker 

  def perform(subject)
    puts "uploading subject #{subject}"
  end
end