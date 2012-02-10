
class Badge extends Spine.Model
  @configure 'Badge', 'title', 'description', 'condition', 'logo_url', 'type', 'levels'  

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

  
  check_condition:(user,level...)=>
    condition = @condition
    console.log "level is #{level}"
    condition.replace(/level/g,level) if level?
    condition= condition+";"
    console.log(condition)
    eval(condition)
    
    
window.Badge = Badge
