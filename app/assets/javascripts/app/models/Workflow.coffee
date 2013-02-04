
class Workflow extends Spine.Model
  @configure 'Workflow','description','primary','name', 'project', 'version', 'questions'

  @extend Spine.Events

  @fetch: ->
    $.getJSON '/active_workflow.json', (data) =>
      for work in data
        Workflow.create work
window.Workflow = Workflow