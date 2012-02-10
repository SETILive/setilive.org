SpinePusher =
  included : ->
    @[key] = @::[key] for key in ['pusher', 'pusherKey', 'pusherChannel']
    @::pusherChannels = {}
    @::openPusher()
    @::setupPusherBindings(@defaultChannel, @pusher)

  setupPusherBindings: (channel, bindings) ->
    for key, method of bindings
      if typeof method == 'string' or 'function'
        @defaultChannel.bind key,(data) =>
          @::[method](data)
      else  
        channel = @createChannel(key)
        @setupPusherBindings channel, method
  
  openPusher:->
    console.log("opening pusher connection")
    if @pusherKey
      @pusherConnection = new Pusher(@pusherKey) 
      @defaultChannel   = @openChannel @pusherChannel
    else  
      throw "You need to specify a pusher key"
  
  openChannel :(channelName)->
    console.log "opening channel ",channelName
    @pusherChannels[channelName] = @pusherConnection.subscribe channelName 
    
  closeChannel :(channelName)->
    if @pusherChannels[channelName]
      @pusherConnection.unsubscribe channelName 
      delete @pusherChannels[channelName] 
    else
      throw "No channel #{channelName} to unsubscribe from"
  
window.SpinePusher= SpinePusher