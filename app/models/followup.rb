class Followup
  include MongoMapper::Document
  key :currnet_stage , Integer , :default => 0

  has_many :signal_groups 
  has_many :subjects

  def inital_signal
    signal_groups.first
  end

  # def trigger_next_stage 
  #   current_stage = current_stage + 1
  #   notify_someone if current_stage == 5 
  # end

  def notify_someone
  end
end
