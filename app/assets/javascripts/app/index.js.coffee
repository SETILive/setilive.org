
#= require json2
#= require spine
#= require jquery.inlineTutorial
#= require spine/manager
#= require spine/ajax
#= require spine/route
#= require spine/local
#= require spine/relation

#= require_tree ./lib
#= require_tree ./modules
#= require_tree ./models
#= require_tree ./controllers
#= require_tree ./views
#= require ./main
#= require_self

class App extends Spine.Controller

  constructor: ->
    super
    @nav = new NavBar(el: $('#top')).el.insertBefore $('#notification_bar')
    @notifications = new Notifications(el: $('#notification_bar')) 
    @append @main = new Main

    # setup events
    Telescope.bind 'fetch', @setInitialNotification

    # Fetch application data
    User.fetch_current_user()
    Badge.fetch()
    Telescope.fetch()
    Workflow.fetch()

    # setup pusher messaging
    @messages = new Messages()

    Spine.Route.setup()

  setInitialNotification: =>
    Telescope.unbind 'fetch', @setInitialNotification

    # Decision tree
    #
    # if follow up window active, use that
    # if not, is new data window active? if so, use that
    # if not, is the telescope active? if so, use that
    # otherwise, say hello
    if (time = (Telescope.findByAttribute('key', 'time_to_followup')).value) > 0
      content = "Followup window closing in <span>#{time}</span> seconds!"
      content_final = "Follow up window has closed. Please wait for new data."

      message =
        name: 'time_to_followup'
        content:
          initial: content
          final: content_final
        type: 'alert'
        meta:
          timer:
            data: time
      Notification.create message

    else if (time = (Telescope.findByAttribute('key', 'time_to_new_data')).value) > 0
      content = "New data expected in <span>#{time}</span> seconds!"
      content_final = "New data available now!"

      message =
        name: 'time_to_new_data'
        content:
          initial: content
          final: content_final
        type: 'alert'
        meta:
          timer:
            data: time
      Notification.create message

    else if (Telescope.findByAttribute('key','telescope_status')).value is 'active'
      message =
        name: 'telescope_status'
        content:
          initial: 'The telescope is active! Get classifying!'
        type: 'alert'
      Notification.create message

    else
      message =
        name: 'default'
        content:
          initial: 'Welcome to SETILive!'
        type: 'alert'

      Notification.create message


window.App = App