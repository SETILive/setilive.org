
class NavBar extends Spine.Controller
  elements:
    '.telescope_status': 'telescope_status'

  events:
    'click .telescope_status': 'showTelescopeStatus'

  constructor: ->
    super
    User.bind 'refresh', @render
    @render()

    Spine.bind 'telescope_status', @render
  
  render: =>
    # Non-blocking render of menu
    telescope_status = Telescope.findByAttribute 'key', 'telescope_status'

    if _.isNull telescope_status
      telescope_status = 'unknown'
    else
      telescope_status = telescope_status.value

    @html @view('navBar')
      user: User.first()
      telescope_status: telescope_status
  
  showTelescopeStatus: ->
    @navigate '/telescope_status'

window.NavBar = NavBar