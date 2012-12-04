
class NavBar extends Spine.Controller
  elements:
    '.telescope_status': 'telescope_status'
    '.next_time_str1': 'next_time_str1'
    '.next_time_str2': 'next_time_str2'

  events:
    'click .telescope_status': 'showTelescopeStatus'

  constructor: ->
    super
    User.bind 'refresh', @render
    @render()

    Spine.bind 'telescope_status', @render
    Spine.bind 'status_change_time', @render
  
  render: =>
    # Non-blocking render of menu
    telescope_status = Telescope.findByAttribute 'key', 'telescope_status'

    if _.isNull telescope_status
      telescope_status = 'unknown'
    else
      telescope_status = telescope_status.value

    change_time = Telescope.findByAttribute 'key', 'telescope_status_change_time'
    change_date = Telescope.findByAttribute 'key', 'telescope_status_change_date'
    if _.isNull change_time
      next_time_str1 = 'waiting'
      next_time_str2 = 'for update...'
    else
      next_time_str1 = change_time.value
      next_time_str2 = change_date.value

    @html @view('navBar')
      user: User.first()
      telescope_status: telescope_status
      next_time_str1: next_time_str1
      next_time_str2: next_time_str2
  
  showTelescopeStatus: ->
    @navigate '/telescope_status'

window.NavBar = NavBar