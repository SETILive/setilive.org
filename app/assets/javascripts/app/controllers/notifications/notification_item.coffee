
class NotificationItem extends Spine.Controller

  constructor: ->
    super
    throw 'Must pass a notification' unless @notification

  render: (notification) =>
    @notification = notification if notification

    console.log 'N: ', @notification

    @html @view('notifications/notification')(@notification)

window.NotificationItem = NotificationItem