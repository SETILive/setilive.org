class Workflow extends Spine.Model
  @configure 'Workflow','description','primary','name', 'project', 'version', 'questions'

  @extend Spine.Events

  
  @fetch_from_url: (url) ->
    $.getJSON url, (data)=>
      #console.log Workflow.create(data[0])


  @fetch: ->
    @fetch_from_url("workflow.json")
  
window.Workflow = Workflow