class TargetInfo extends Spine.Controller 
  constructor: (args) ->
    super
    @location = args.location
    @render()

  render: =>
    @html @view('targets_info')
      location: @location

window.TargetInfo = TargetInfo