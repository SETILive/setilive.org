class Badge extends Spine.Model
  @configure 'Badge', 'title', 'description', 'condition', 'logo_url','large_logo_url', 'type', 'levels', 'post_text'

  constructor: ->
    super 
    @testUser(User.first()) if User.count()==1
    User.bind 'refresh', =>
      @testUser User.first()

  @fetch: ->
    $.getJSON '/badges.json', (data) =>
      for badge in data
        Badge.create(badge)
      Badge.trigger 'refresh'

  testUser: (user) =>
    if @type=='one_off'
      if @check_condition(user)
        user.award(@)
    else
      for level in @levels
        if @check_condition(user, level)
          user.award(@,level)

  maxLevel:=>
    @levels[@levels.length-1]

  facebookString: (username, level = null) =>
    reply= @post_text
    if(level?)
      reply = reply.replace(/level/g,level)
    reply = reply.trim()
    reply = "#{username} #{reply}"
    reply
    
  twitterString: (username, level = null) =>
    reply= @post_text
    if(level?)
      reply = reply.replace(/level/g,level)
    reply = reply.trim()
    reply = "#{username} #{reply}."
    reply
    
  check_condition: (user, level...) =>
    condition = @condition
    condition.replace(/level/g,level) if level?
    condition= condition+";"
    eval(condition)
    
    
window.Badge = Badge
