
class TelescopeStatusPage extends Spine.Controller

  elements:
    '#telescopeStatus': 'telescopeStatus'

  constructor: ->
    super

  active: ->
    super
    TelescopeStatus.bind 'refresh', @render
    TelescopeStatus.fetch()

  deactivate: ->
    super
    TelescopeStatus.unbind 'refresh', @render

  render: =>
    status = TelescopeStatus.first()
    @html @view('telescope_status/telescope_status_page')({status: status.status})
    new Metrics({el: $("#global_stats")})

window.TelescopeStatusPage = TelescopeStatusPage