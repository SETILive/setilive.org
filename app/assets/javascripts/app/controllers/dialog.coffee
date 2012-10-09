
class Dialog extends Spine.Controller
  events:
    'click #close': 'closeDialog'

  constructor: (params) ->
    super
    @content = params.content
    @render()

  render: =>
    @html @view('classify/dialog')
      content: @content

    @el.css 'display', 'table'

  closeDialog: (e) =>
    e.stopPropagation()
    @el.css 'display', 'none'

window.Dialog = Dialog