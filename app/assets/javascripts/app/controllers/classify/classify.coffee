
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

        if _.isNull Telescope.findByAttribute('key','telescope_status')
          Spine.bind 'telescope_status', @initialTelescopeSetup
        else
          Spine.trigger 'telescope_status'

  deactivate: =>
    super
    Spine.unbind 'startWorkflow'
    Spine.unbind 'closeWorkflow'
    Spine.unbind 'nextBeam'
    Spine.unbind 'clearSignals'
    Spine.unbind 'doneClassification'
    Subject.unbind 'create'
    Subject.unbind 'done'
    Workflow.unbind 'workflowDone'
    @subjects.release()

  initialTelescopeSetup: =>
    Spine.unbind 'telescope_status', @initialTelescopeSetup # Ensures this only actually happens once per session.
    if Telescope.findByAttribute('key','telescope_status').value is 'inactive'
      @showInactiveDialog()

  showInactiveDialog: =>
    dialog = new Dialog({el: $('#dialog-underlay'), content: @view('classify/dialog_content_statusinactive')()})

window.Classify = Classify