
class Messages extends Spine.Controller

  pusherKey: '***REMOVED***'
  pusherChannel: 'dev-telescope'
  pusher: 
    'target_changed': 'onPusherSourceChange'
    'new_data': 'onPusherNewData'
    'followUpTrigger': 'onPusherFollowUpTrigger'
    'status_changed': 'onPusherTelescopeStatusChange'
    # 'stats_update': 'onPusherUpdateStats'

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
      if typeof method == 'string' or 'function'
        @defaultChannel.bind key, (data) ->
          console.log 'bound to spine ', method, ' and key: ', key
          Spine.trigger method, data

window.Messages = Messages