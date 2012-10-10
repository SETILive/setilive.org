
class Telescope extends Spine.Model
  @configure 'Telescope', 'key', 'value'

  @fetch: ->
    $.getJSON '/retrieve_system_state.json', (data) ->
      for datum in data
        Telescope.create datum
        if datum.key is 'telescope_status'
          Spine.trigger datum.key

  @updateTelescopeStatus: ->
    $.getJSON '/telescope_status.json', (status) ->
      current_status = Telescope.findByAttribute 'key', 'telescope_status'

      if _.isNUll current_status
        Telescope.create {key: 'telescope_status', value: status}
      else
        Telescope.update current_status.id, {value: status}


window.Telescope = Telescope