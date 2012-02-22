class Observation
  include MongoMapper::Document

  key :type , String, :validate_in => ['inital','on','off','tutorial']
  key :data , Array 
  key :data_url, String
  key :image_url, String
  key :thumb_url, String
  key :beam_no, Integer
  key :zooniverse_id, String
  key :width, Integer
  key :height, Integer
  key :uploaded, Boolean, :default => false

  
  belongs_to :source 
  belongs_to :subject
  # belongs_to :follow_up
  before_create :create_zooniverse_id
  after_create :process



  def create_zooniverse_id
    self.zooniverse_id = "OSL#{ beam_no || 0 }#{ subject.zooniverse_id[4..-1] }"
  end

  def process 
    ObservationUploader.perform_async self.id
  end

end
