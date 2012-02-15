class ZooniverseUser
  include MongoMapper::Document

  key :zooniverse_user_id, Integer
  key :email, String
  key :api_key, String 
  key :name, String 
  key :favourite_ids, Array 
  key :badges, Array
  key :total_classifications , Integer, :default => 0
  key :total_follow_ups , Integer,  :default => 0
  key :total_signals , Integer,  :default => 0
  key :talk_click_count, Integer, :default => 0 
  key :classification_count, Hash
  key :signal_count, Hash
  key :follow_up_count, Hash
  key :sweeps_status, String, :in =>['none', 'in','out'], :default=>'none'
  key :seen_subjects, Array

  timestamps! 
  
  one :zooniverse_user_extra_info
  many :classifications 
  many :favourites, :in => :favourite_ids, :class_name => "Subject"

  def award_badges 
    Badge.not_awarded(self).each do |badge|
      badge.award_to self if badge.award?(self)
    end
  end

  def add_favourite(subject)
    self.favourites <<  subject
    save
  end

  def remove_favourite(subject)
    puts self.favourite_ids
    self.favourites.delete!(subject)
    puts self.favourite_ids
    save
  end
 
  def update_classification_stats(classification)
     update_classification_count classification
     # update_signal_count         classification
     # award_badges                classification
     RedisConnection.setex "online_#{self.id}", 10*60, 1
  end

  def update_classification_count (clasificaiton)
    puts "updating classificaiton count"
    self.total_classifications=  self.total_classifications+1
    self.save
     # classification.subject.classification_count.
  end

  def update_signal_count(classification)
    source = classification.subject.source 
    signal_count = classification.subject_signals.count
    self.signal_count[source.id] ||=0
    self.signal_count[source.id] += signal_count
  end

end
