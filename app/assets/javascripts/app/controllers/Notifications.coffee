class Notifications extends Spine.Controller

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
    console.log 'setting up local '
    for model, events of @localEvents
      for trigger, response of events
        console.log "setting up ", window[model]
        console.log " trigger ", trigger
        console.log "responce ", @[response]
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
    console.log data
    data['size'] = "50"
    @addNotification 'badge_awarded',
      data : data
      badgeTemplate : @view('badge')(data)
      facebookTemplate : @view('facebookBadge')(data)

  addNotification:(type, data)=>
    notification= $(@view("notifications/#{type}_notification")(data) )
    @append notification
    $(notification).slideDown 1000, =>
      setTimeout =>
       @removeNotification(notification)
      ,4000

  removeNotification:(notification)->
    # $(notification).fadeOut 10000, ->
      # $(notification).remove()
  

window.Notifications= Notifications