class Notifications extends Spine.Controller

  pusherKey     : "***REMOVED***"
  pusherChannel : 'telescope'
  pusher: 
      "target_changed" : "sourceChange"
      "new_data" : "newData"
      "status_changed" : "telescopeStatusChange"

  localEvents:
    "User":
      "badgeAwarded" :  "badgeAwarded"

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
    console.log @localEvents
    for model, events of @localEvents
      for trigger, response of events
        window[model].bind(trigger,@[response])

  sourceChange: (data)=> 
    @addNotification('source_change',data)

  newData: (data)=>
    console.log("NEW DATA")
    @addNotification('new_data',data)

  telescopeStatusChange: (data)=> 
    console.log("STATUS CHANGE")
    @addNotification('telescope_status_changed',data)
  
  badgeAwarded:(data)=>
    console.log("badge awarded ")
    @addNotification('badge_awarded',data)  

  addNotification:(type, data)=>
    console.log type, data
    notification= $(@view("notifications/#{type}_notification")(data) )
    @append notification
    $(notification).slideDown 1000, =>
      setTimeout =>
       @removeNotification(notification)
      ,4000

  removeNotification:(notification)->
    $(notification).fadeOut 10000, ->
      $(notification).remove()
  

window.Notifications= Notifications