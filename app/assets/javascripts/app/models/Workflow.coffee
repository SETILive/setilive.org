
class Workflow extends Spine.Model
  @configure 'Workflow','description','primary','type','name', 'project', 'questions'
  @extend(Spine.Events)
  
  @fetch_from_url: (url) ->
    $.getJSON(url, (data)->
      console.log(data)
      workflow= new Workflow(data)
      workflow.save() 
    )
  
window.Workflow = Workflow