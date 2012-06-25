class Observation
  include MongoMapper::Document

  key :type , String, :validate_in => ['inital','on','off','tutorial', 'simulation']
  key :data_key, String
  key :data_url, String
  key :image_url, String
  key :simulation_url, String
  key :simulation_thumb_url, String

  key :simulation_reveal_url, String
  key :thumb_url, String
  key :beam_no, Integer
  key :zooniverse_id, String
  key :width, Integer
  key :height, Integer
  key :uploaded, Boolean, :default => false
  key :has_simulation, Boolean, :default=>false
  key :simulation_ids , Array
  
  belongs_to :source 
  belongs_to :subject
  many       :subject_signals
  has_one    :signal_finder

  many :simulations, :in => :simulation_ids
  many :signal_groups
  
  scope :simulation , where(:has_simulation=>true)
  scope :real       , where(:has_simulation=>false)
  
  belongs_to :follow_up
  before_create :create_zooniverse_id
  after_create :processNow
  
  timestamps! 


  def create_zooniverse_id
    self.zooniverse_id = "OSL#{ beam_no || 0 }#{ subject.zooniverse_id[4..-1] }"
  end

  def process 
    ObservationUploader.perform_async self.id
  end

  def processNow 
    ObservationUploader.new.perform self.id
  end

  def get_data
     data = JSON.parse(RedisConnection.get(data_key)) unless uploaded
  end

  def data
    if data_url?
      data = HTTParty.get data_url
      data= JSON.parse(data.match(/\[.*\]/).to_s)
    elsif RedisConnection.exists data_key
      data = JSON.parse(RedisConnection.get(data_key))
    end 
    data
  end

  # def update_signal_groups
  #   if subject.classification_count > 10
  #     new_signals = self.subject_signals.where(:signal_group=>nil).collect{|ss| ss.to_fof}
  #     groups  = self.signal_group.collect{ |signal_group| signal_group.to_fof }
  #     groups  = groups + new_signals
  #     fof_finder = FOFFinder.create_with_groups groups, 1
  #     fof_finder.find_groups 
  #   end
  # end
  
end
