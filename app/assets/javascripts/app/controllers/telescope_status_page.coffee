
class TelescopeStatusPage extends Spine.Controller

  elements:
    '#telescopeStatus': 'telescopeStatus'

  constructor: ->
    super

  active: ->
    super
    Spine.bind 'telescope_status', @render
    Telescope.fetch()

  deactivate: ->
    super
    Spine.unbind 'telescope_status', @render

  render: =>
    telescope_status = Telescope.findByAttribute('key','telescope_status')
    @html @view('telescope_status/telescope_status_page')({status: telescope_status.value})
    new Metrics({el: $("#global_stats")})

window.TelescopeStatusPage = TelescopeStatusPage