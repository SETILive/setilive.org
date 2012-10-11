
class Telescope extends Spine.Model
  @configure 'Telescope', 'key', 'value'

  @fetch: ->
    $.getJSON '/retrieve_system_state.json', (data) =>
      for datum in data
        Telescope.create datum
        if datum.key is 'telescope_status'
          Spine.trigger datum.key
      super

  @updateTelescopeStatus: ->
    $.getJSON '/telescope_status.json', (status) ->
      current_status = Telescope.findByAttribute 'key', 'telescope_status'

      if _.isNull current_status
        Telescope.create {key: 'telescope_status', value: status}
      else
        Telescope.update current_status.id, {value: status}

      Spine.trigger 'telescope_status'

  @updateNewData: ->
    $.getJSON '/time_to_new_data.json', (time) ->
      current_time = Telescope.findByAttribute 'key', 'time_to_new_data'

      if _.isNull current_time
        Telescope.create {key: 'time_to_new_data', value: time}
      else
        Telescope.update current_time.id, {value: status}

      Spine.trigger 'time_to_new_data'

  @updateFollowup: ->
    $.getJSON '/time_to_followup.json', (time) ->
      current_time = Telescope.findByAttribute 'key', 'time_to_followup'

      if _.isNull current_time
        Telescope.create {key: 'time_to_followup', value: time}
      else
        Telescope.update current_time.id, {value: status}

      Spine.trigger 'time_to_followup'

window.Telescope = Telescope