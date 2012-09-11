class Notifications extends Spine.Controller

  elements :
    '.notification' : 'notifications'
    '.notification_count' : 'notificationCount'

  events:
    'click .dismiss_button' : 'removeNotification'

  pusherKey     : "***REMOVED***"
  # pusherChannel : 'telescope'
  pusherChannel : 'dev'
  pusher: 
      "target_changed" : "sourceChange"
      "new_data" : "newData"
      "followUpTrigger" : "followUpTrigger"
      "status_changed" : "telescopeStatusChange"
      "stats_update" : "updateStats"
   
  constructor: ->
    super

    @setupLocal()
    @setupPusher() if Pusher?
    # @append "<div class='notification_count'></div>"

  openPusher: ->
    if @pusherKey
      @pusherConnection = new Pusher(@pusherKey) 
      @defaultChannel   = @openChannel @pusherChannel
    else  
      throw "You need to specify a pusher key"

  openChannel: (channelName) ->
    @pusherChannels[channelName] = @pusherConnection.subscribe channelName 

  setupPusherBindings: (channel, bindings) ->
    for key, method of bindings
      if typeof method == 'string' or 'function'
        @defaultChannel.bind key, @[method]
      else  
        channel = @createChannel(key)
        @setupPusherBindings channel, method
  
  setupPusher: =>
    @pusherChannels = {}
    @openPusher()
    @setupPusherBindings(@defaultChannel, @pusher)

  setupLocal: =>
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

  telescopeStatusChange: (data)=> 
    $(".telescope_status_changed").remove()
    Spine.trigger('target_status_changed', data)
    @addNotification('telescope_status_changed',data)

  followUpTrigger:()=>
    console.log("here")
    @addNotification('followUpTriggered',{})
  
  badgeAwarded:(data)=>
    data['size'] = "50"
    data['user'] = User.first().name
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

  newData: (data) =>
    notification = @addNotification('new_data', data, 'alert')
    time = (data.time).seconds().fromNow()
    $('.kepler-time').countdown(
      until: time
      compact: true
      format: 'MS'
      description: ''
      onExpiry: @changeNewData notification
    )

  changeNewData: (e) =>
    notification_content = @view('notifications/new_data_available_notification')
    console.log(notification_content)
    $(e.currentTarget).parents('notification').html notification_content

  addNotification: (type, data, style="badge") =>
    notificationTemplate = @view("notifications/#{type}_notification")
    notification = @view('notifications/notification')
      data: data
      notificationTemplate: notificationTemplate
      notificationType: type
      notificationStyle: style

    @prepend $(notification)
    @updateNotificationCount()
    @notifications.fadeIn 700

  removeNotification: (e) =>
    @updateNotificationCount()
    $(e.currentTarget).parents('notification').fadeOut 700, ->
      $(e.currentTarget).parents('notification').remove()

  updateNotificationCount: =>
    if @notifications.length > 1
      @notificationCount.show()
      @notificationCount.html 0
    else
      @notificationCount.hide()

  removeAllNotifications: ->
    $(notifications).remove()

window.Notifications= Notifications