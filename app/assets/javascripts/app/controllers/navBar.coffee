
class NavBar extends Spine.Controller
  elements:
    '.telescope_status': 'telescope_status'

  events:
    'click .telescope_status': 'showTelescopeStatus'

  constructor: ->
    super
    User.bind 'refresh', @render
    TelescopeStatus.bind 'refresh', @render
    @render()

    # Spine.bind 'target_status_changed', (data) =>
    #   @telescope_status = data
    #   @render()
  
  render: =>
    # Non-blocking render of menu
    if TelescopeStatus.count() == 0
      telescope_status = 'unknown'
    else
      telescope_status = TelescopeStatus.first().status

    @html @view('navBar')
      user: User.first()
      telescope_status: telescope_status
  
  showTelescopeStatus: ->
    @navigate '/telescope_status'

window.NavBar = NavBar