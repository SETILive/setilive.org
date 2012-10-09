
class Messages extends Spine.Controller

  pusherKey: '***REMOVED***'
  pusherChannel: 'dmode-telescope'
  pusher: 
    'target_changed': 'onPusherSourceChange'
    'new_data': 'onPusherNewData'
    'followUpTrigger': 'onPusherFollowUpTrigger'
    'status_changed': 'onPusherTelescopeStatusChange'
    'stats_update': 'onPusherUpdateStats'

  constructor: ->
    @pusherChannels = {}
    @setupPusher() if Pusher?

  setupLocal: =>
    # might want to break this into controllers
    # likely will
    # User.bind 'badge_awarded', @badgeAwarded
    # User.bind 'tutorial_badge_awarded', @tutorialBadgeAwarded
    # User.bind 'favourited', @favourited

  setupPusher: =>
    @openPusher()
    @setupPusherBindings @defaultChannel, @pusher

  openPusher: ->
    if @pusherKey
      @pusherConnection = new Pusher(@pusherKey)
      @defaultChannel = @openChannel @pusherChannel
    else  
      throw "You need to specify a pusher key"

  openChannel: (channelName) ->
    @pusherChannels[channelName] = @pusherConnection.subscribe channelName 

  setupPusherBindings: (channel, bindings) ->
    for key, method of bindings
      channel.bind key, @[method]

  onPusherSourceChange: (data) ->
    console.log 'Source Change: ', data
    message = message: data
    Notification.create message

  onPusherNewData: (data) ->
    console.log 'New Data: ', data
    message = message: data
    Notification.create message

  onPusherFollowUpTrigger: (data) ->
    console.log 'Follw Up!: ', data
    message = message: data
    Notification.create message

  onPusherTelescopeStatusChange: (data) ->
    telescope_status = status: data
    TelescopeStatus.refresh telescope_status, {clear: true}

    switch data
      when 'inactive' then content = 'The telescope is now inactive.'
      when 'active' then content = 'The telescope is now active.'
      
    message =
      name: 'telescope_status'
      content: content
      type: 'alert'

    Notification.create message

  onPusherUpdateStats: (data) ->
    console.log 'Source Change: ', data
    message = message: data
    Notification.create message

window.Messages = Messages