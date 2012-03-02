class NavBar extends Spine.Controller
  events :
    'click .telescope_status' : 'showTelescopeStatus'

  constructor: ->
    super
    @telescope_status = 'unknown'
    @render()

    User.bind('refresh',@render)

    Spine.bind 'target_status_changed', (data)=>
      @telescope_status = data
      @render()

    $.getJSON '/telescope_status.json', (data)=>
      @telescope_status = data.status
      @render()
  
  render:=>
    @html @view('navBar')
      user : User.first()
      telescope_status : @telescope_status 
  
  showTelescopeStatus:=>
    window.location = '/telescope_status'

window.NavBar=NavBar