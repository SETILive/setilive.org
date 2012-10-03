
class TelescopeStatus extends Spine.Model
  @configure 'TelescopeStatus', 'status'

  constructor: ->
    super

  @fetch: ->
    $.getJSON '/telescope_status.json', (status) ->
      TelescopeStatus.refresh status, {clear: true}

window.TelescopeStatus = TelescopeStatus