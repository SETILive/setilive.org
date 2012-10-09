
$.fn.notification = ->
  element_id = $(@).data 'id'
  element_id or= $(@).parents('[data-id]').data('id')
  Notification.find element_id

class Notifications extends Spine.Controller
  elements:
    '.notification': 'notifications'

  events:
    'click .dismiss_button' : 'remove'

  constructor: ->
    super
    Notification.bind 'create', @add
    Notification.bind 'refresh', @addAll

  add: (notification) =>
    notification = new NotificationItem(notification: notification)
    @prepend notification.render()

  addAll: =>
    Notification.each @add

  remove: (e) =>
    notification = $(e.target).notification()
    notification.destroy()

  ###
  setupLocal: =>
    User.bind("badge_awarded", @badgeAwarded)
    User.bind("tutorial_badge_awarded", @tutorialBadgeAwarded)
    User.bind("favourited", @favourited)

  updateStats: (data) =>
    Spine.trigger 'updateStats', data

  favourited: =>
    @addNotification('favourited',{})

  sourceChange: (data) =>
    Spine.trigger('target_target_changed', data)
    @addNotification('source_change',data)

  telescopeStatusChange: (data) =>
    $(".telescope_status_changed").remove()
    Spine.trigger('target_status_changed', data)
    @addNotification('telescope_status_changed',data)

  followUpTrigger: =>
    console.log("here")
    @addNotification('followUpTriggered',{})
  
  badgeAwarded: (data) =>
    data['size'] = "50"
    data['user'] = User.first().name
    @addNotification 'badge_awarded',
      data: data
      badgeTemplate: @view('badge')(data)
      facebookTemplate: @view('facebookBadge')(data)
      twitterTemplate: @view('twitterBadge')(data)

  tutorialBadgeAwarded: =>
    data = 
      'size' : "50"
      badge :
        'id' : 0
        "title": "Tutorial"
        "description": "Classify level number of waterfalls"
        "logo_url": "assets/badges/200px/aliens-200.png"
        "large_logo_url": "assets/badges/250px/aliens-250.png"
        "type": "oneoff"
        "post_text": "just compleated the tutorial on SETILive"
      
    @addNotification 'badge_awarded',
      data : data
      badgeTemplate : @view('badge')(data)
      # facebookTemplate : @view('facebookBadge')(data)
      # twitterTemplate  : @view('twitterBadge')(data)

  newData: (data) =>
    notification = @addNotification('new_data', data, 'alert')
    time = (data.time).seconds().fromNow()
    $('.kepler-time').countdown(
      until: time
      compact: true
      format: 'MS'
      description: ''
      onExpiry: @newDataAvailable
    )

  newDataAvailable: ->
    $(@).parent().html 'New data available! Refresh the page for fresh data.'

  addNotification: (type, data, style="badge") =>
    notificationTemplate = @view("notifications/#{type}_notification")
    notification = @view('notifications/notification')
      data: data
      notificationTemplate: notificationTemplate
      notificationType: type
      notificationStyle: style

    @prepend $(notification)
    # @updateNotificationCount()
    @notifications.fadeIn 700

  removeNotification: (e) =>
    # @updateNotificationCount()
    $(e.currentTarget).parent().fadeOut 700, ->
      $(e.currentTarget).parent().remove()

  updateNotificationCount: =>
    if @notifications.length > 1
      @notificationCount.show()
      @notificationCount.html 0
    else
      @notificationCount.hide()

  removeAllNotifications: ->
    $(notifications).remove()
###
window.Notifications= Notifications
