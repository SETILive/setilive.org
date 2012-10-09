
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
      date.setSeconds date.getSeconds() + @notification.meta.timer
      @el.find('span').countdown {
          until: date
          compact: true
          description: ''
          format: 'MS'
        }

    @show()
    @

  show: =>
    @el.fadeIn 700

  remove: =>
    @el.fadeOut 700, =>
      @el.remove()

window.NotificationItem = NotificationItem