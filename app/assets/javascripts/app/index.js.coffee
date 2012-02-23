# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

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
#= require_self


class SetiLiveController extends Spine.Controller
  events :
    "click #start_searching_button" : ->
      window.location = '/classify'
    "click #view_all_button" : ->
      window.location = '/profile'
    "click #sign_in_button" : ->
      window.location = '/classify'
  notificationsOn : true
  starFieldOn : true
  badgesOn : true

  constructor:->
    super 
    @prepend new NavBar()
    if @starFieldOn
      @stars = new Stars(el:$("#star_field"))
      Source.fetch()

    else
      $("#star_field").remove()
      
    if @notificationsOn
      @notifications= new Notifications(el: $("#notification_bar")) 
    else
      $("#notification_bar").remove()
    
    if @badgesOn
      Badge.fetch()

    User.fetch_current_user()


class HomePage extends SetiLiveController
  elements:
    '#home_content': 'home_content'
    '#most_recent_badge': 'home_badge'
    "#subjects" : "subjects"

  constructor: ->
    super
    @stats = new Stats({el:$("#global_stats")})
    @home_content.html @view('home_main_content')()
    
    Classification.fetchRecent (observations)=>
      $("#subjects").html @view('observation')(observations)

    @home_badge.html @view('home_badge')
    
    User.bind 'create', (user)=>
      @home_badge.html @view('home_badge')
        user: user
    

class ClassificationPage extends SetiLiveController
  constructor: ->
    super  
    @subjects = new Subjects({el:$("#waterfalls")})
    @info = new Info({el: $("#info")})

    Workflow.fetch_from_url("/workflows.json")
    Subject.fetch_next_for_user()

class TutorialPage extends SetiLiveController
  constructor: ->
    super  
    @subjects = new Subjects({el:$("#waterfalls")})
    @info = new Info({el: $("#info")})

    $("#classify-area").inlineTutorial 
      steps: window.tutorialSteps

    setTimeout((->$("#classify-area").inlineTutorial("start")),200)
      
    Workflow.fetch_from_url("/workflows.json")
    Subject.get_tutorial_subject()

class LoginPage extends SetiLiveController

  notificationsOn : false 
  badgesOn : false 
  constructor:->
    super 

    $("span").click ->
        $(@).hide()
        $(@).parent().find('input').focus()
    
    $("input").focus ->
        $(@).parent().find('span').hide()
    
    $("input").blur ->
        $(@).parent().find('span').show() if $(@).val()==""
     
    
class AboutPage extends SetiLiveController
  starFieldOn: false
  badgesOn: false

  constructor: ->
    super

class TargetsIndexPage extends SetiLiveController
  badgesOn: false

  constructor: ->
    super 
    new TargetsIndex(el:$("#sources"))

class TargetsShowPage extends SetiLiveController
  badgesOn: false

  constructor: ->
    super 
    new TargetsShow(el:$("#source"))

class ProfilePage extends SetiLiveController
  constructor:->
    super
    new Profile(el: $("#profile"))

class BadgePage extends SetiLiveController
  constructor:->
    super
    new Badges(el:$("#badgePage"))

class GenericAboutPage extends SetiLiveController
  starFieldOn : false
  badgesOn: false

  constructor:->
    super
    
class GalleryPage extends SetiLiveController
  starFieldOn : false
  badgesOn: false

  constructor:->
    super  
    
class TelescopePage extends SetiLiveController
  elements :
    '#telescopeStatus' : "telescopeStatus"
  constructor:->
    super
    new Stats({el:$("#global_stats")})
    $.getJSON '/telescope_status.json', (status)=>
      @telescopeStatus.html @view('telescopeStatusExplination')
        status: status.status
    Spine.bind 'target_status_changed',(status)=>
      @telescopeStatus.html @view(telescopeStatusExplination)
        status: status.status
  
window.HomePage = HomePage
window.ClassificationPage = ClassificationPage
window.TutorialPage = TutorialPage
window.LoginPage = LoginPage
window.ClassificationPage = ClassificationPage
window.AboutPage = AboutPage
window.TargetsIndexPage = TargetsIndexPage
window.TargetsShowPage = TargetsShowPage
window.ProfilePage = ProfilePage
window.BadgePage = BadgePage
window.TelescopePage = TelescopePage
window.GenericAboutPage = GenericAboutPage
window.GalleryPage = GalleryPage
# Run jQuery animations at 20 FPS
jQuery.fx.interval = 50
