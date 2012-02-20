class TalkCreator
  include HTTParty
  base_uri 'http://talk.setilive.org'
  basic_auth '***REMOVED***', '***REMOVED***'
  format :json
  
  def self.talk_create(hash)
    result = create_on_talk hash
    return { 'success' => false } unless [200, 201].include?(result.first)
    result = result.last
    
    if result['user']
      { 'success' => true }
    else
      { 'success' => false, 'message' => result['error'] }
    end
  end
  
  def self.create_on_talk(hash)
    begin
      result = post '/observation_groups', :body => { :observation_group => hash }
      [result.response.code.to_i, result]
    rescue
      [500, { 'error' => 'Talk is currently unavailable' }]
    end
  end
end