
class Messages extends Spine.Controller

  pusherKey: '***REMOVED***'
  pusherChannel: 'telescope'
  pusher: 
    'target_changed': 'onPusherSourceChange'
    'new_telescope_data': 'onPusherNewData'
    'time_to_followup': 'onPusherTimeToFollowUp'
    'status_changed': 'onPusherTelescopeStatusChange'

  constructor: ->
    @pusherChannels = {}

    # Build Pusher channel based on environment
    if window.location.hostname is 'devwww.setilive.org' or window.location.hostname is '0.0.0.0' or window.location.hostname is 'localhost'
      @pusherChannel = 'dev-' + @pusherChannel

    if window.location.hostname is '0.0.0.0' or window.location.hostname is 'localhost'
      @pusherChannel = 'dmode-' + @pusherChannel

    @setupPusher() if Pusher?

    Telescope.bind 'telescope_status'

  setupLocal: =>
    User.bind 'badge_awarded', @onBadgeAwarded
    User.bind 'tutorial_badge_awarded', @onTutorialBadgeAwarded
    User.bind 'favourited', @onFavourited

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
      content:
        initial: content
      type: 'alert'

    Notification.create message

  onPusherNewData: (data) =>
    t = Telescope.findByAttribute('key', 'time_to_new_data')
    t.updateAttribute('value', data)
    @displayNewData()

  onPusherTimeToFollowUp: (data) =>
    t = Telescope.findByAttribute('key', 'time_to_followup')
    t.updateAttribute('value', data)
    @displayFollowUp()

  onPusherTelescopeStatusChange: (data) =>
    t = Telescope.findByAttribute('key', 'telescope_status')
    t.updateAttribute('value', data)
    @displayTelescopeStatus()
    Spine.trigger 'telescope_status'

  onFavourited: =>

  onBadgeAwarded: =>

  onTutorialBadgeAwarded: ->

  displayTelescopeStatus: ->
    t = Telescope.findByAttribute('key','telescope_status')
    switch t.value
      when 'inactive' then content = 'The telescope is now inactive. Thanks for classifying!'
      when 'active' then content = 'The telescope is now active! Get classifying!'

    message =
      name: t.key
      content:
        initial: content
      type: 'alert'

    Notification.create message

  displayNewData: ->
    t = Telescope.findByAttribute('key','time_to_new_data')
    content = "New data expected in <span>#{t.value}</span> seconds!"
    content_final = "New data available now!"
    message =
      name: t.key
      content:
        initial: content
        final: content_final
      type: 'alert'
      meta:
        timer:
          data: data
    Notification.create message

  displayFollowUp: ->
    t = Telescope.findByAttribute('key','time_to_followup')
    content = "The follow up window is closing in <span>#{t.value}</span> seconds!"
    content_final = "The follow up window has closed. Please wait for new data."

    message =
      name: t.key
      content:
        initial: content
        final: content_final
      type: 'alert'
      meta:
        timer:
          data: time
          onTimerEnd: @displayNewData
    Notification.create message

  displayDefault: ->
    message =
      name: 'default'
      content:
        initial: 'Welcome to SETILive!'
      type: 'alert'

    Notification.create message

window.Messages = Messages