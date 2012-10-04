
class Classify extends Spine.Controller

  elements:
    '#classify-area': 'classify_area'

  constructor: ->
    super

  active: (params) =>
    super
    @html @view 'classify/classify'

    @delay =>
      @subjects = new Subjects({el: $("#waterfalls")})
      @info = new Info({el: $("#info")})

      Workflow.fetch()

      if params.type is 'tutorial'
        @classify_area.inlineTutorial
          steps: tutorialSteps

        setTimeout (=> @classify_area.inlineTutorial("start")), 200
        Subject.get_tutorial_subject()
      else
        Subject.fetch_next_for_user()

window.Classify = Classify