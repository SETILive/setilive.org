class Workflow extends Spine.Model
  @configure 'Workflow','description','primary','name', 'project', 'version', 'questions'

  @extend Spine.Events
  
   @fetch_from_url: (url) ->
    $.getJSON(url, (data)->
      subject=  Workflow.create(data)
    )

  @fetch: ->
    @fetch_from_url("workflow.json")
  
window.Workflow = Workflow