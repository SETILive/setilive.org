# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

#= require json2
#= require spine
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
#= require_self


class SetiLiveController extends Spine.Controller
  events :
    "click #start_searching_button" : ->
      window.location = '/classify'
    "click #view_all_button" : ->
      window.location = '/profile'
    
  notificationsOn : true

  constructor:->
    super 
    @prepend new NavBar()
    @stars = new Stars(el:$("#star_field"))
    if @notificationsOn
      @notifications= new Notifications(el: $("#notification_bar")) 
    else
      $("#notification_bar").remove()
    User.fetch_current_user()
    Source.fetch()
    Badge.fetch()


class HomePage extends SetiLiveController
  elements:
    '#home_content': 'home_content'
    '#most_recent_badge': 'home_badge'

  constructor: ->
    super
    @stats = new Stats({el:$("#global_stats")})
    @home_content.html @view('home_main_content')
      subjects : [1..4]
    @home_badge.html @view('home_badge')
      user: User.first

class ClassificationPage extends SetiLiveController
  constructor: ->
    super  
    @subjects = new Subjects({el:$("#waterfalls")})
    @info = new Info({el: $("#info")})
    Workflow.fetch_from_url("/workflows.json")

class LoginPage extends SetiLiveController

  notificationsOn : false 
  
  constructor:->
    super 

    $("span").click(->
        $(@).hide()
        $(@).parent().find('input').focus()
    )
    $("input").focus( ->
        $(@).parent().find('span').hide()
    )
    $("input").blur( ->
        $(@).parent().find('span').show() if $(@).val()==""
        # if $(@).val()==""
        #   $(@).val($(@).data().placeholder) if $(@).val()==""
        #   $(@).css("color", "grey")
    )
    
class AboutPage extends SetiLiveController
  constructor: ->
    super
    $('#star_field').hide()

class TargetsIndexPage extends SetiLiveController
  constructor: ->
    super 
    new TargetsIndex(el:$("#sources"))

class TargetsShowPage extends SetiLiveController
  constructor: ->
    super 
    new TargetsShow(el:$("#source"))

class ProfilePage extends SetiLiveController
  constructor:->
    super
    new Profile(el: $("#profile"))
  
window.HomePage = HomePage
window.ClassificationPage = ClassificationPage
window.LoginPage = LoginPage
window.ClassificationPage = ClassificationPage
window.AboutPage = AboutPage
window.TargetsIndexPage = TargetsIndexPage
window.TargetsShowPage = TargetsShowPage
window.ProfilePage = ProfilePage

# Run jQuery animations at 20 FPS
jQuery.fx.interval = 50
