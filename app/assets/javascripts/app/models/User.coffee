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
    for badge in @badges 
      if testBadge.id == badge.id 
        if level? and badge.levels.indexOf(level)
          return true
    return false
window.User = User