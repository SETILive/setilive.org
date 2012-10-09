
class Messages extends Spine.Controller

  pusherKey: '***REMOVED***'
  pusherChannel: 'dmode-dev-telescope'
  pusher: 
    'target_changed': 'onPusherSourceChange'
    'new_telescope_data': 'onPusherNewData'
    'time_to_followup': 'onPusherTimeToFollowUp'
    'status_changed': 'onPusherTelescopeStatusChange'

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

    content = "Telescope is now looking at #{data}."
    message =
      name: 'source_change'
      content: content
      type: 'alert'

    Notification.create message

  onPusherNewData: (data) ->
    console.log 'New Data: ', data
    content = "New data expected in <span>#{data}</span> seconds!"

    message =
      name: 'time_to_new_data'
      content: content
      type: 'alert'
      meta:
        timer: data

    Notification.create message

  onPusherTimeToFollowUp: (data) ->
    console.log 'Follow Up!: ', data
    content = "Followup window closing in <span>#{data}</span> seconds!"

    message =
      name: 'time_for_followups'
      content: content
      type: 'alert'
      meta:
        timer: data

    Notification.create message

  onPusherTelescopeStatusChange: (data) ->
    telescope_status = status: data
    TelescopeStatus.refresh telescope_status, {clear: true}

    switch data
      when 'inactive' then content = 'The telescope is now inactive. Thanks for classifying!'
      when 'active' then content = 'The telescope is now active!'

    message =
      name: 'telescope_status'
      content: content
      type: 'alert'

    Notification.create message

window.Messages = Messages