
class Workflow extends Spine.Model
  @configure 'Workflow','description','primary','name', 'project', 'version', 'questions'

  @extend Spine.Events

  @fetch: ->
    $.getJSON '/active_workflow.json', (data) =>
      Workflow.create data
  
window.Workflow = Workflow