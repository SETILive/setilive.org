
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
    Spine.Route.setup()

    # setup events
    Telescope.bind 'fetch', @setInitialNotification

    User.fetch_current_user()
    Badge.fetch()
    Telescope.fetch()

    # setup pusher messaging
    @messages = new Messages()

  setInitialNotification: =>
    Telescope.unbind 'fetch', @setInitialNotification
    if (Telescope.findByAttribute('key','telescope_status')).value is 'active'
      message =
        name: 'default'
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