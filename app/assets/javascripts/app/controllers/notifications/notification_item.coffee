
class NotificationItem extends Spine.Controller
  className: 'alert'
  tag: 'li'

  constructor: ->
    super
    throw 'Must pass a notification' unless @notification
    @notification.bind 'destroy', @remove

  render: (notification) =>
    @notification = notification if notification
    @html @view('notifications/notification')(@notification)
    @el.attr 'data-id', @notification.id

    # handle timers
    if not _.isUndefined @notification.meta and not _.isUndefined @notification.meta.timer
      date = new Date()
      date.setSeconds date.getSeconds() + @notification.meta.timer.data
      @el.find('span').countdown {
          until: date
          compact: true
          description: ''
          format: 'MS'
          expiryText: @notification.meta.timer.onTimerEnd
        }

    @show()
    @

  show: =>
    @el.fadeIn 550, 'easeInExpo'

  cleanupNotification: =>
    @el.find('.content').html @notification.content.final

  remove: =>
    @el.fadeOut 550, 'easeInExpo', =>
      @el.remove()

window.NotificationItem = NotificationItem