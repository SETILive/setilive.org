class Zooniverse
  include HTTParty
  base_uri 'https://www.zooniverse.org'
  basic_auth 'api', '***REMOVED***'
  format :xml
  
  def self.create_user(hash)
    result = create_remote_user hash
    return { 'success' => false } unless [200, 201].include?(result.first)
    result = result.last
    
    if result['user']
      { 'success' => true, 'user' => result['user'] }
    else
      messages = result['errors']['error']
      messages = messages.is_a?(Array) ? messages : [messages]
      { 'success' => false, 'messages' => messages }
    end
  end
  
  def self.create_remote_user(hash)
    begin
      result = post '/api/users.xml', :body => { :user => hash }
      [result.response.code.to_i, result]
    rescue
      [500, { 'errors' => { 'error' => ['Zooniverse signup is currently unavailable'] } }]
    end
  end
end