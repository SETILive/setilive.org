
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
    @show()
    @

  show: =>
    @el.fadeIn 700

  remove: =>
    @el.remove()

window.NotificationItem = NotificationItem