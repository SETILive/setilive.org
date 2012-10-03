
class Classify extends Spine.Controller

  constructor: ->
    super

  active: ->
    super
    @html @view 'classify/classify'

    Workflow.fetch()
    @render()

    # window.tutorial = false
    # window.location.hash='notification_bar'

  render: =>
    @subjects = new Subjects({el:$("#waterfalls")})
    @info = new Info({el: $("#info")})
    Subject.fetch_next_for_user()

window.Classify = Classify