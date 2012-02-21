class Badge extends Spine.Model
  @configure 'Badge', 'title', 'description', 'condition', 'logo_url','large_logo_url', 'type', 'levels'  

  constructor:->
    super 
    @testUser(User.first()) if User.count()==1
    User.bind 'refresh', =>
      @testUser User.first()

  @fetch:->
    $.getJSON '/badges.json', (data)=>
      for badge in data
        Badge.create(badge)
      Badge.trigger('refresh')

  testUser:(user)=>
    if @type=='one_off'
      if @check_condition(user)
        user.award(@)
    else
      for level in @levels
        if @check_condition(user, level)
          user.award(@,level)

  maxLevel:=>
    @levels[@levels.length-1]

  facebookString:(level=null)=>
    reply= ""
    if(level?)
      reply+= "Level #{level} of the "
    reply += "#{@title} Badge acquired on SETILive"
    reply
    
  twitterString:(level=null)=>
    reply= "I just earned  "
    if(level?)
      reply+= " level #{level} of  "
    reply += "the #{@title} Badge on www.SETILive.org"
    reply
    
  check_condition:(user,level...)=>
    condition = @condition
    condition.replace(/level/g,level) if level?
    condition= condition+";"
    eval(condition)
    
    
window.Badge = Badge
