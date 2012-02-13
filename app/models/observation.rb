class Observation
  include MongoMapper::Document

  key :type , String, :validate_in => ['inital','on','off']
  key :data , Array 
  key :beam_no, Integer
  key :zooniverse_id, String


  belongs_to :source 
  belongs_to :subject
  # belongs_to :follow_up
  before_save :create_zooniverse_id

  def upload_data_packet_to_s3(data)
    self.data_url = "#{SiteConfig.s3_subject_bucket}/subject_#{self.id}.bson" if S3Upload.upload_asset("subject_#{self.id}.bson", data)
  end

  def create_zooniverse_id
    self.zooniverse_id = "OSL#{ beam_no || 0 }#{ subject.zooniverse_id[4..-1] }"
  end

end
