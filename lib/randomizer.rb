module Randomizer
  extend ActiveSupport::Concern
  
  included do
    before_create lambda{ send :"#{ self.class.randomizer_key }=", rand }
    
    class << self
      attr_accessor :randomizer_key
    end
  end
  
  module ClassMethods
    def randomize_with(key)
      @randomizer_key = key
    end
    
    def random(*args)
      opts = { :limit => 1 }.update(args.extract_options!)
      opts[:selector] ||= args.first || { }
      
      number = rand
      criteria = where(opts[:selector]).limit(opts[:limit]).sort(:random_number.asc)
      result = criteria.where({ @randomizer_key => { :$gte => number } }).all
      
      criteria = where(opts[:selector]).limit(opts[:limit] - result.length).sort(:random_number.desc)
      result += criteria.where({ @randomizer_key => { :$lt => number } }).all if result.length < opts[:limit]
      result
    end
  end
end
