
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

  onPusherNewData: (data) ->
    console.log 'New Data: ', data
    content = "New data expected in <span>#{data}</span> seconds!"
    content_final = "New data available now!"

    message =
      name: 'time_to_new_data'
      content:
        initial: content
        final: content_final
      type: 'alert'
      meta:
        timer: data

    Notification.create message

  onPusherTimeToFollowUp: (data) ->
    console.log 'Follow Up!: ', data
    content = "Followup window closing in <span>#{data}</span> seconds!"
    content_final = "Follow up window has closed. Please wait for new data."

    message =
      name: 'time_for_followups'
      content:
        initial: content
        final: content_final
      type: 'alert'
      meta:
        timer:
          data: data
          onTimerEnd: @onPusherNewData 

    Notification.create message

  onPusherTelescopeStatusChange: (data) ->
    telescope_status = Telescope.findByAttribute('key','telescope_status')
    Telescope.update telescope_status.id, {value: data}

    switch telescope_status.value
      when 'inactive' then content = 'The telescope is now inactive. Thanks for classifying!'
      when 'active' then content = 'The telescope is now active! Get classifying!'

    message =
      name: telescope_status.key
      content:
        initial: content
      type: 'alert'

    Notification.create message
    Spine.trigger telescope_status.key

  onFavourited: =>

  onBadgeAwarded: =>

  onTutorialBadgeAwarded: =>

  checkForNewData: ->

window.Messages = Messages