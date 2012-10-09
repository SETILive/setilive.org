
class Classify extends Spine.Controller

  elements:
    '#classify-area': 'classify_area'

  constructor: ->
    super

    if Workflow.count() == 0
      Workflow.fetch()


  active: (params) =>
    super
    @html @view 'classify/classify'

    @delay =>
      @subjects = new Subjects({el: $("#waterfalls")})
      @info = new Info({el: $("#info")})

      if params.type is 'tutorial'
        @classify_area.inlineTutorial
          steps: tutorialSteps

        setTimeout (=> @classify_area.inlineTutorial("start")), 230
        Subject.get_tutorial_subject()
      else
        Subject.fetch_next_for_user()
        if TelescopeStatus.count() > 0
          @showInactiveDialog()
        else
          TelescopeStatus.bind 'refresh', @showInactiveDialog

  deactivate: =>
    super
    Spine.unbind 'startWorkflow'
    Spine.unbind 'closeWorkflow'
    Spine.unbind 'nextBeam'
    Spine.unbind 'clearSignals'
    Spine.unbind 'doneClassification'
    TelescopeStatus.unbind 'refresh', @showInactiveDialog
    Workflow.unbind 'workflowDone'
    @el.empty()

  showInactiveDialog: =>
    status = TelescopeStatus.first().status
    if status is 'inactive'
      dialog = new Dialog({el: $('#dialog-underlay'), content: @view('classify/dialog_content_statusinactive')()})

window.Classify = Classify