class CheckResults
  include Sidekiq::Worker 
  sidekiq_options :retry => false
  def perform(subject_id)
    s= Subject.find(subject_id)
    s.check_for_signals
  end
end