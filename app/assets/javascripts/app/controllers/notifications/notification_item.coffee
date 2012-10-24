
class NotificationItem extends Spine.Controller
  tag: 'li'

  constructor: ->
    super
    throw 'Must pass a notification' unless @notification
    @notification.bind 'destroy', @remove

  render: (notification) =>
    @notification = notification if notification

    switch @notification.type
      when 'badge'
        # legacy badge support
        @el.addClass 'flash'
        @notification.content['size'] = '50'
        @notification.content['user'] = User.first().name
        @html @view('notifications/badge_awarded_notification')({
            data: @notification.content
            badgeTemplate: @view('profile/badge')(@notification.content)
            facebookTemplate: @view('profile/facebookBadge')(@notification.content)
            twitterTemplate: @view('profile/twitterBadge')(@notification.content)
          })
      when 'flash'
        @el.addClass 'flash'
        @html @view('notifications/flash_notification')(@notification)
        @el.attr 'data-id', @notification.id
      when 'alert'
        @html @view('notifications/notification')(@notification)
        @el.attr 'data-id', @notification.id

        # handle timers
        if not _.isUndefined @notification.meta and not _.isUndefined @notification.meta.timer
          date = new Date()
          date.setSeconds date.getSeconds() + @notification.meta.timer.data

          options =
            until: date
            compact: true
            description: ''
            format: 'MS'

          if not _.isUndefined @notification.meta.timer.onTimerEnd
            options.onExpiry = @notification.meta.timer.onTimerEnd
          else if not _.isUndefined @notification.content.final
            options.onExpiry = @cleanupNotification

          @el.find('span').countdown options

    @show()
    @

  show: =>
    @el.fadeIn 550, 'easeInExpo'

  cleanupNotification: =>
    @el.find('.content').html @notification.content.final

  remove: =>
    @el.fadeOut 550, 'easeOutExpo', =>
      @el.remove()
    
window.NotificationItem = NotificationItem