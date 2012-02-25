class User extends Spine.Model
  @configure 'User', 'zooniverse_user_id', 'api_key', 'name', 'favourites', 'badges', 'total_classifications', 'classification_count', 'signal_count',"follow_up_count","total_follow_ups", "total_signals","sweeps_status"
  
  constructor: ->
    super 
    @id = @zooniverse_user_id 


  @fetch_current_user :->
    console.log("grabbing current user")
    $.getJSON '/current_user.json', (data) =>
      data.favourites = data.favourite_ids
      u = User.create(data)
      User.trigger('refresh', u )
    
  award:(badge,level...)=>
    unless @hasBadge(badge,level)
      if level.length>0
        level = level[level.length-1] 
      else 
        level = null

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
      success: (response)->
        console.log("badge ",response)

  hasBadge:(testBadge,level...)=>
    for badge in @badges 
      if testBadge.id == badge.id 
        if level.length>0 and badge.levels?
          if badge.levels.indexOf(level[0])
            return true
        else 
          return true 
    return false

  maxLevelForBadge:(badge)=>
    return null if badge.type=='one_off'
    level=0
    for item in @badges
      level= item.level if item.id==badge.id and item.level >level
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
    console.log "deleteing ",observation_id
    $.ajax 
      type: 'DELETE'
      url: "/favourites/#{observation_id}"
      dataType: 'json'
      success: (response)=>
        @favourites.splice( @favourites.indexOf( observation_id),1)
        @save()
        callback() if callback?

window.User = User