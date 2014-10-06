
class Messages extends Spine.Controller

  pusherKey: '***REMOVED***'
  pusherChannel: 'telescope'
  pusher: 
    'target_changed': 'onPusherSourceChange'
    'new_telescope_data': 'onPusherNewData'
    'time_to_followup': 'onPusherTimeToFollowUp'
    'status_changed': 'onPusherTelescopeStatusChange'
    'next_status_changed': 'onPusherTelescopeStatusChangeTime'
    'followUpTrigger': 'onPusherFollowUpTrigger'
    'fakeFollowUpTrigger': 'onPusherFakeFollowUpTrigger'

  constructor: ->
    @pusherChannels = {}

    # Build Pusher channel based on environment
    host = window.location.hostname
    # Use dev mode channel if client on localhost or un-dotted hostname (local
    # network with name service)
    if host is '0.0.0.0' or host is 'localhost' or host is '127.0.0.1' or 
        host.indexOf('.') is -1
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

  onPusherSourceChange: (data) =>
    unless window.isTutorial
      t = Telescope.findByAttribute('key', 'target_change')
      val = data.target.name
      if val == undefined
        val = 'SETI ' + data.target_id
      t.updateAttribute('value', val)
      @displayTargetChange()
      Spine.trigger 'target_changed'

  onPusherNewData: (data) =>
    unless window.isTutorial
      t = Telescope.findByAttribute('key', 'time_to_new_data')
      t.updateAttribute('value', data)
      @displayNewData()

  onPusherTimeToFollowUp: (data) =>
    unless window.isTutorial
      t = Telescope.findByAttribute('key', 'time_to_followup')
      t.updateAttribute('value', data)
      @displayFollowup()

  onPusherTelescopeStatusChange: (data) =>
    t = Telescope.findByAttribute('key', 'telescope_status')
    t.updateAttribute('value', data)
    @displayTelescopeStatus()
    Spine.trigger 'telescope_status'
    
  onPusherTelescopeStatusChangeTime: (data) =>
    Telescope.updateTelescopeStatusChangeTime(data)

  onPusherFollowUpTrigger: (data) =>
    unless window.isTutorial
      t = Telescope.findByAttribute('key', 'follow_up_trigger')
      t.updateAttribute('value', data)
      @displayFollowUp()
      Spine.trigger 'followUpTrigger'

  onPusherFakeFollowUpTrigger: (data) =>
    unless window.isTutorial
      t = Telescope.findByAttribute('key', 'fake_follow_up_trigger')
      t.updateAttribute('value', data)
      @displayFakeFollowUp()
      Spine.trigger 'fakeFollowUpTrigger'

  onBadgeAwarded: (data) =>
    message = 
      name: 'badge'
      content: data
      type: 'badge'

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

  displayTargetChange: ->
    t = Telescope.findByAttribute('key','target_change')
    content = "The telescope has moved one of its beams to point at target #{t.value}."
    message =
      name: t.key
      content:
        initial: content
      type: 'flash'
    Notification.create message

  displayFollowUp: ->
    t = Telescope.findByAttribute('key','follow_up_trigger')
    content = "SETILive sent a #{t.value} follow-up request to the Allen Telescope Array."
    message =
      name: t.key
      content:
        initial: content
      type: 'flash'
    Notification.create message

  displayFakeFollowUp: ->
    t = Telescope.findByAttribute('key','fake_follow_up_trigger')
    content = "TESTING 1-2-3...SETILive sent a #{t.value} artificial follow-up request to the Allen Telescope Array"
    message =
      name: t.key
      content:
        initial: content
      type: 'flash'
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
        initial: 'Welcome to SETILive!'
      type: 'alert'

    Notification.create message

window.Messages = Messages