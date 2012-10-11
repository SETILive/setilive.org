
class Telescope extends Spine.Model
  @configure 'Telescope', 'key', 'value'

  @fetch: =>
    $.getJSON '/retrieve_system_state.json', (data) =>
      for datum in data
        t = Telescope.create datum
        if datum.key is 'telescope_status'
          Spine.trigger 'telescope_status'
        else if datum.key is 'time_to_new_data' or datum.key is 'time_to_followup'
          t.countdown()
          t.bind 'update', t.countdown
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

  countdown: =>
    if @value < 1
      return
    @timer = window.setInterval @tick, 1000

  tick: =>
    @value -= 1
    console.log 'time: ', @value
    if @value < 1
      clearInterval @timer


window.Telescope = Telescope