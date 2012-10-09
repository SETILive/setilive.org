
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

    User.fetch_current_user()
    Badge.fetch()
    TelescopeStatus.fetch()

    # setup pusher messaging
    @messages = new Messages()

window.App = App