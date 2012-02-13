class User extends Spine.Model
  @configure 'User', 'zooniverse_user_id', 'api_key', 'name', 'favourites', 'badges', 'total_classifications', 'classification_count', 'signal_count',"follow_up_count","total_follow_ups", "total_signals"
  
  constructor: ->
    super 
    @id = @zooniverse_user_id 

  @fetch_current_user :->
    $.getJSON '/current_user.json', (data) =>
      data.favourites = data.favourite_ids
      User.create(data)
      User.trigger('refresh')
    
  award:(badge,level...)=>
    unless @hasBadge(badge,level)
      level = nil unless level?
      data= {id: badge.id, level:level, name: badge.title}
      @badges.push data
      User.trigger "badge_awarded", data
  
  hasBadge:(testBadge,level...)=>
    console.log("testBadge is ",testBadge," level is ",level)
    for badge in @badges 
      console.log "ids ",testBadge.id, " badge.id  ", badge.id 
      if testBadge.id == badge.id 
        if level.length>0 
          if badge.levels.indexOf(level[0])
            return true
        else 
          return true 
    return false
window.User = User