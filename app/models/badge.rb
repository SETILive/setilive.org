class Badge
  include MongoMapper::Document

  key :title, String, :required => true 
  key :description, String, :required => true
  key :condition, String , :required => true 
  key :logo_url , String,  :required => true
  key :large_logo_url , String,  :required => true
  key :post_text, String
  key :type   , String , :required => true , :validate_in => ['one_off', 'cumulative']
  key :levels, Array 

  def award?(user,subject)
    MongoMapper.connection(condition > 1 )
  end

  def details 
    {
      title: self.title,
      description: self.description,
      type: self.type
    }
  end

  def award_to (user)
    user.badges << self 
    PusherConnection.send("badges", "awarded", self.to_json)
  end
end
