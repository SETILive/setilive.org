class CheckForResults
  include Sidekiq::Worker 
  def perform(subject_id)
    s= Subject.find(subject_id)
    s.check_for_signals
  end
end