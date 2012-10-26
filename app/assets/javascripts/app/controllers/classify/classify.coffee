
class Classify extends Spine.Controller

  elements:
    '#classify-area': 'classify_area'

  constructor: ->
    super
    @user_set = -1
    @dialog_shown = false

    User.bind 'refresh', (user) =>
      @user_set = if user then 1 else 0

  active: (params) =>
    super
    if @user_set < 0
      @timeout_id = window.setTimeout @active, 1000, params
    else
      if @user_set > 0
        @setupPage params
      else
        window.location = '/login'

  setupPage: (params) =>
    @html @view 'classify/classify'

    @delay =>
      @cleanup()
      @subjects = new Subjects({el: $("#waterfalls")})
      @info = new Info({el: $("#info")})

      if not _.isUndefined params.type and params.type is 'tutorial'
        if @tutorial_step?
          @tutorial = @classify_area.inlineTutorial
            current_step_id: @tutorial_step
            steps: tutorialSteps
        else
          @tutorial = @classify_area.inlineTutorial
            steps: tutorialSteps

        setTimeout (=> @classify_area.inlineTutorial("start")), 230
        Subject.get_tutorial_subject()
      else
        Subject.fetch_next_for_user()

        Spine.one 'telescope_status', @initialTelescopeSetup
        if not _.isNull(Telescope.findByAttribute('key', 'telescope_status')) and not @dialog_shown
          @dialog_shown = true
          Spine.trigger 'telescope_status'

  deactivate: =>
    super
    @cleanup()
    @el.empty()

  cleanup: =>
    window.clearTimeout @timeout_id
    Spine.unbind 'startWorkflow'
    Spine.unbind 'closeWorkflow'
    Spine.unbind 'nextBeam'
    Spine.unbind 'clearSignals'
    Spine.unbind 'doneClassification'

    Workflow.unbind()
    Subject.unbind()

    if @subjects?
      @subjects.release()

    if @info?
      @info.release()

    if @tutorial?
      @tutorial_step = @tutorial.find('#inline_tutorial_box').data('step')
      @tutorial.remove()

  initialTelescopeSetup: =>
    if Telescope.findByAttribute('key','telescope_status').value is 'inactive'
      dialog = new Dialog({el: $('#dialog-underlay'), content: @view('classify/dialog_content_statusinactive')()})

window.Classify = Classify