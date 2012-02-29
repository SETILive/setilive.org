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
  getUser : true

  constructor:->
    super 
    new NavBar(el:$("#top")).el.insertBefore $('#star_field')
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

    if @getUser
      User.fetch_current_user()
  
  activatePlaceholders: ->
    $('span.placeholder').click ->
        $(@).hide()
        $(@).parent().find('input').focus()
    
    $('input').focus ->
        $(@).parent().find('span.placeholder').hide()
    
    $('input').blur ->
        $(@).parent().find('span.placeholder').show() if $(@).val() is ''


class HomePage extends SetiLiveController
  elements:
    '#home_content': 'home_content'
    '#most_recent_badge': 'home_badge'
    "#subjects" : "subjects"

  constructor: ->
    super
    @stats = new Stats({el:$("#global_stats")})
    @home_content.html @view('home_main_content')()
    
    User.bind 'refresh', =>
      @renderObservations()

    Classification.fetchRecent (observations)=>
      @observations= observations
      @renderObservations()

    @home_badge.html @view('home_badge')
  
    User.bind 'create', (user)=>
      @home_badge.html @view('home_badge')
        user: user

  renderObservations:=>
    self= @
    $("#subjects").html @view('observation')
        observations: @observations
        user: User.first()

    $("#subjects .favourite").click ->
        observation_id = $(@).data().id 
        User.first().addFavourite observation_id, =>
          self.renderObservations()
            # @.find("img").attr("src", "favorited_button.png")
    $("#subjects .favourited").click ->
        observation_id = $(@).data().id 
        User.first().removeFavourite observation_id, =>
          self.renderObservations()

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
  getUser : false
  
  constructor: ->
    super
    @activatePlaceholders()

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
  notificationsOn: false 

  constructor:->
    super
    
class GalleryPage extends SetiLiveController
  starFieldOn : false
  badgesOn: false
  notificationsOn: false 
  
  elements:
    '#gallery': 'gallery'

  constructor:->
    super  
    @gallery.html @view('galleryWaterfalls')(window.galleryWaterfalls)
    
class TelescopePage extends SetiLiveController
  elements :
    '#telescopeStatus' : "telescopeStatus"
  constructor:->
    super
    new Stats({el:$("#global_stats")})
    $.getJSON '/telescope_status.json', (status)=>
      status='training' if status=='active'
      @telescopeStatus.html @view('telescopeStatusExplination')
        status: status.status
    Spine.bind 'target_status_changed',(status)=>
      status='training' if status=='active'
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
