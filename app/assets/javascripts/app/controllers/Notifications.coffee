class Notifications extends Spine.Controller

  elements :
    '.notification' : 'notifications'

  events:
    'click .dismiss_button' : 'removeNotification'

  pusherKey     : "***REMOVED***"
  pusherChannel : 'telescope'
  pusher: 
      # "target_changed" : "sourceChange"
      # "new_data" : "newData"
      "status_changed" : "telescopeStatusChange"
      "stats_update" : "updateStats"

  localEvents:
    "User":
      "badge_awarded" :  "badgeAwarded"

  constructor: ->
    super
    @setupLocal()
    @setupPusher() if Pusher?

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
    for model, events of @localEvents
      for trigger, response of events
        window[model].bind trigger, (data)=>
          @[response](data)

  updateStats:(data)=>
    Spine.trigger('updateStats',data)  

  sourceChange: (data)=> 
    Spine.trigger('target_target_changed', data)
    @addNotification('source_change',data)

  newData: (data)=>
    @addNotification('new_data',data)

  telescopeStatusChange: (data)=> 
    Spine.trigger('target_status_changed', data)
    @addNotification('telescope_status_changed',data)
  
  badgeAwarded:(data)=>
    data['size'] = "50"
    @addNotification 'badge_awarded',
      data : data
      badgeTemplate : @view('badge')(data)
      facebookTemplate : @view('facebookBadge')(data)
      twitterTemplate  : @view('twitterBadge')(data)


  addNotification:(type, data)=>
    notificationTemplate= @view("notifications/#{type}_notification")
    notification = @view('notifications/notification')
      data: data
      notificationTemplate : notificationTemplate
    
    @append $(notification)

    @notifications.slideDown 1000

  removeNotification: (e)->
    console.log e
    $(e.currentTarget).parent().fadeOut 1000, ->
      @.remove()
  

window.Notifications= Notifications