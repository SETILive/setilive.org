
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
    User.bind 'badge_awarded', @onBadgeAwarded
    # User.bind 'tutorial_badge_awarded', @onTutorialBadgeAwarded
    # User.bind 'favourited', @onFavourited

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
    t = Telescope.findByAttribute('key', 'target_change')
    t.updateAttribute('value', data.target_id)
    @displayTargetChange()

  onPusherNewData: (data) =>
    t = Telescope.findByAttribute('key', 'time_to_new_data')
    t.updateAttribute('value', data)
    @displayNewData()

  onPusherTimeToFollowUp: (data) =>
    t = Telescope.findByAttribute('key', 'time_to_followup')
    t.updateAttribute('value', data)
    @displayFollowup()

  onPusherTelescopeStatusChange: (data) =>
    t = Telescope.findByAttribute('key', 'telescope_status')
    t.updateAttribute('value', data)
    @displayTelescopeStatus()
    Spine.trigger 'telescope_status'

  onBadgeAwarded: (data) =>
    message = 
      name: 'badge'
      content: data
      type: 'flash'

    Notification.create message

  displayTelescopeStatus: ->
    t = Telescope.findByAttribute('key','telescope_status')
    switch t.value
      when 'inactive' then content = 'Telescope inactive - Please classify Archive data.'
      when 'active' then content =   'Telescope active! - Waiting for more live data ...'
      when 'replay' then content =   'Telescope simulator active! - Waiting for more replayed data ...'
      else
        content = 'Welcome to SETI Live!'

    message =
      name: t.key
      content:
        initial: content
      type: 'alert'

    Notification.create message

  displayTargetChange: =>
    t = Telescope.findByAttribute('key','target_change')
    content = "The telescope is now looking at target #{t.value}."
    message =
      name: t.key
      content:
        initial: content
      type: 'alert'
    Notification.create message

  displayNewData: =>
    t = Telescope.findByAttribute('key','time_to_new_data')
    content = "New data expected in <span>#{t.value}</span> seconds"
    content_final = "New data available now!"
    message =
      name: t.key
      content:
        initial: content
        final: content_final
      type: 'alert'
      meta:
        timer:
          data: t.value
    Notification.create message

  displayFollowup: =>
    t = Telescope.findByAttribute('key','time_to_followup')
    content = "Live data now available - follow-up window open for <span>#{t.value}.</span>"
    content_final = "Follow-up window closed - more live data expected soon ..."

    message =
      name: t.key
      content:
        initial: content
        final: content_final
      type: 'alert'
      meta:
        timer:
          data: t.value
    Notification.create message

  displayDefault: ->
    message =
      name: 'default'
      content:
        initial: 'Welcome to SETILive! Update Preview (Beta)'
      type: 'alert'

    Notification.create message

window.Messages = Messages