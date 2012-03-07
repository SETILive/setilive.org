class Workflow extends Spine.Model
  @configure 'Workflow','description','primary','name', 'project', 'version', 'questions'

  @extend Spine.Events

  
  @fetch_from_url: (url) ->
    $.getJSON url, (data)=>
      Workflow.create(data)


  @fetch: ->
    @fetch_from_url("/active_workflow.json")
  
window.Workflow = Workflow