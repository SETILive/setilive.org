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



class HomePage extends Spine.Controller
  constructor: ->
    super
    @stars = new Stars(el:$("#star_field"))
    @stats = new Stats({el:$("#stats")})
    Source.fetch()

class ClassificationPage extends Spine.Controller
  constructor: ->
    super
    @stars = new Stars(el:$("#star_field"))
    
    @subjects = new Subjects({el:$("#waterfalls")})
    @info = new Info({el: $("#info")})
    
    Source.fetch()
    Workflow.fetch_from_url("/workflows.json")

class LoginPage extends Spine.Controller 
  constructor:->
    super 
    @stars = new Stars(el:$("#star_field"))
    $("input").each(->
        $(@).attr('data-placeholder',$(@).val())
    )
    $("input").focus( ->
        console.log("here")
        $(@).val("")
        $(@).css("color", "black")
    )
    $("input").blur( ->
        if $(@).val()==""
          $(@).val($(@).data().placeholder) if $(@).val()==""
          $(@).css("color", "grey")
    )
    Source.fetch()
    
class AboutPage extends Spine.Controller
  constructor: ->
    super
    $('#star_field').hide()

class TargetsIndexPage extends Spine.Controller
  constructor: ->
    super 
    @stars = new Stars(el:$("#star_field"))
    new TargetsIndex(el:$("#sources"))
    Source.fetch()

class TargetsShowPage extends Spine.Controller
  constructor: ->
    super 
    @stars = new Stars(el:$("#star_field"))
    new TargetsShow(el:$("#source"))
    Source.fetch()

window.HomePage = HomePage
window.ClassificationPage = ClassificationPage
window.LoginPage = LoginPage
window.ClassificationPage = ClassificationPage
window.AboutPage = AboutPage
window.TargetsIndexPage = TargetsIndexPage
window.TargetsShowPage = TargetsShowPage

