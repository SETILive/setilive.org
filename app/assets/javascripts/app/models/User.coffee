class User extends Spine.Model
  @configure 'User', 'zooniverse_user_id', 'api_key', 'name', 'favourites', 'badges', 'total_classifications', 'classification_count', 'signal_count',"follow_up_count","total_follow_ups", "total_signals","sweeps_status", "login_count","talk_click_count"
  
  constructor: ->
    super 
    @id = @zooniverse_user_id 


  @fetch_current_user :->
    $.getJSON '/current_user.json', (data) =>
      data.favourites = data.favourite_ids
      u = User.create(data)
      User.trigger('refresh', u )
    
  award:(badge,level...)=>
    if level.length>0
      level = level[level.length-1] 
    else 
      level = null

    unless @hasBadge(badge,level)
      data= {id: badge.id, level:level, name: badge.title}
      @badges.push data
      User.trigger "badge_awarded", {badge: badge, level: level }
      @persistBadge(data)
  
  persistBadge:(data)=>
    $.ajax
      type: 'POST'
      url: '/awardBadge'
      data: data
      dataType: 'json'

  hasBadge:(testBadge,level...)=>
    level = level[0]
    for badge in @badges 
      if testBadge.id == badge.id 
        if level?
          if badge.level >= level
            return true
        else 
          return true
    return false

  maxLevelForBadge:(badge)=>
    return null if badge.type=='one_off'
    level=0
    for item in @badges
      if item.id==badge.id
       if item.level*1 >=level*1
        level = item.level  
    level

  addFavourite:(observation_id, callback=null)=>
    $.ajax 
      type: 'POST'
      url: '/favourites/'
      data: {observation_id : observation_id}
      dataType: 'json'
      success: (response)=>
        @favourites.push(observation_id)
        @save()
        callback() if callback?

  removeFavourite:(observation_id, callback=null)=>
    $.ajax 
      type: 'DELETE'
      url: "/favourites/#{observation_id}"
      dataType: 'json'
      success: (response)=>
        @favourites.splice( @favourites.indexOf( observation_id),1)
        @save()
        callback() if callback?

window.User = User