class Notifications extends Spine.Controller

  elements :
    '.notification' : 'notifications'
    '.notification_count' : 'notificationCount'

  events:
    'click .dismiss_button' : 'removeNotification'

  pusherKey     : "***REMOVED***"
  pusherChannel : 'telescope'
  pusher: 
      "target_changed" : "sourceChange"
      # "new_data" : "newData"
      "status_changed" : "telescopeStatusChange"
      "stats_update" : "updateStats"

   
  constructor: ->
    super
    @setupLocal()
    @setupPusher() if Pusher?
    # @append "<div class='notification_count'></div>"

  openPusher:->
    if @pusherKey
      @pusherConnection = new Pusher(@pusherKey) 
      @defaultChannel   = @openChannel @pusherChannel
    else  
      throw "You need to specify a pusher key"

  openChannel :(channelName)->
    @pusherChannels[channelName] = @pusherConnection.subscribe channelName 

  setupPusherBindings: (channel, bindings) ->
    for key, method of bindings
      if typeof method == 'string' or 'function'
        @defaultChannel.bind key, @[method]
      else  
        channel = @createChannel(key)
        @setupPusherBindings channel, method
  
  setupPusher:=>
    @pusherChannels={}
    @openPusher()
    @setupPusherBindings(@defaultChannel, @pusher)

  setupLocal:=>
    User.bind("badge_awarded", @badgeAwarded)
    User.bind("tutorial_badge_awarded", @tutorialBadgeAwarded)
    User.bind("favourited", @favourited)
 

    # for model, events of @localEvents
    #   for trigger, response of events
    #     window[model].bind trigger, (data)=>
    #       rp = response
    #       @[rp](data)

  updateStats:(data)=>
    Spine.trigger('updateStats',data)  

  favourited: => 
    @addNotification('favourited',{})


  sourceChange: (data)=> 
    Spine.trigger('target_target_changed', data)
    @addNotification('source_change',data)
  newData: (data)=>
    @addNotification('new_data',data)

  telescopeStatusChange: (data)=> 
    $(".telescope_status_changed").remove()
    Spine.trigger('target_status_changed', data)
    @addNotification('telescope_status_changed',data)
  
  badgeAwarded:(data)=>
    data['size'] = "50"
    @addNotification 'badge_awarded',
      data : data
      badgeTemplate : @view('badge')(data)
      facebookTemplate : @view('facebookBadge')(data)
      twitterTemplate  : @view('twitterBadge')(data)

  tutorialBadgeAwarded:=>
    data = 
      'size' : "50"
      badge :
        'id' : 0
        "title": "Tutorial"
        "description": "Classify level number of waterfalls"
        "logo_url": "assets/badges/200px/aliens-200.png"
        "large_logo_url": "assets/badges/250px/aliens-250.png"
        "type": "oneoff"
        "post_text": "just compleated the tutorial on SETILive"
      
    @addNotification 'badge_awarded',
      data : data
      badgeTemplate : @view('badge')(data)
      # facebookTemplate : @view('facebookBadge')(data)
      # twitterTemplate  : @view('twitterBadge')(data)


  addNotification:(type, data)=>
    notificationTemplate= @view("notifications/#{type}_notification")
    notification = @view('notifications/notification')
      data: data
      notificationTemplate : notificationTemplate
      notificationType : type
    
    @prepend $(notification)
    @updateNotificationCount()
    @notifications.fadeIn 1000

  removeNotification: (e)=>
    @updateNotificationCount()
    $(e.currentTarget).parent().fadeOut 1000, ->
      $(e.currentTarget).parent().remove()

  updateNotificationCount: =>
    if @notifications.length > 1
      @notificationCount.show()
      @notificationCount.html 0
    else
      @notificationCount.hide()

  removeAllNotifications: ->
    $(notifications).remove()

window.Notifications= Notifications