class ZooniverseUser
  include MongoMapper::Document

  key :zooniverse_user_id, Integer
  key :email, String
  key :api_key, String 
  key :name, String 
  key :favourite_ids, Array 
  key :badges, Hash
  key :total_classifications , Integer
  key :classification_count, Hash
  key :signal_count, Hash
  key :follow_up_count, Hash
  timestamps! 
  
  one :zooniverse_user_extra_info
  many :classifications 
  many :favourites, :class_name => "Subject", :in => :favourite_ids
  many :badges, :class_name => "Badge", :in => :badge_ids

  def award_badges 
    Badge.not_awarded(self).each do |badge|
      badge.award_to self if badge.award?(self)
    end
  end

  def add_favourite(subject)
    favourites<< subject
    save
  end

  def remove_favourite(subject)
    # favourite_ids.
  end
  
  def update_classification_stats(classification)
     update_classification_count classification
     update_signal_count         classification
     award_badges                classification
  end

  def update_signal_count(classificaiton)
    source = classification.subject.source 
    signal_count = classification.subject_signals.signal_count
    self.signal_count[source.id] ||=0
    self.signal_count[source.id] += signal_count
  end

  def update_signal_count(classification)
    source = classification.subject.source
    self.classification_count[source.id] += 1 
  end
end
