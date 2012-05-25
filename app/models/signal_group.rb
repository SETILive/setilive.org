class SignalGroup
  include MongoMapper::Document
  key :intercept, Float
  key :gradient, Float
  key :angle, Float
  key :confidence, Float 

  key :characteristics, Array
  key :real, Boolean

  belongs_to :observation
  belongs_to :source
  # many :subject_signals, :in => subject_signal_ids

  before_save :check_real

  def check_real
    real = true if confidence > 0.2 and real==false
  end

  # def in_one_beam
  #   for observation.signal_groups.each do |group|
  #     unless group.id == id 
  #       if (group.angle - angle).abs < 0.1 and (group.intercept- intercept).abs < 0.1
  #         return false
  #       end 
  #     end
  #   end
  #   return true
  # end

  def check_vertical?
    angle < 0.1
  end

  def trigger_followup?
    unless check_vertical or in_one_beam==false 
      return true
    end
    return false 
  end
  
end
