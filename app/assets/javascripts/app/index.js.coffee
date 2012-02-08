# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

#= require json2
#= require jquery
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



class App extends Spine.Controller
  constructor: ->
    super
    @stars = new Stars(el:$("#star_field"))
    
    @subjects = new SubjectsSeq({el:$("#waterfalls")})
    @info = new Info({el: $("#info")})
    @stats = new Stats({el:$("#stats")})
    
    Source.fetch()
    Workflow.fetch_from_url("/workflow.json")
    

window.App = App
    