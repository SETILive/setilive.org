
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
        else if datum.key is 'telescope_status_change'
          @updateTelescopeStatusChangeTime(datum.value)
          
      t = Telescope.create {key: 'target_change', value: 0}
      t = Telescope.create {key: 'follow_up_trigger', value: 'ON Level 0'}
      t = Telescope.create {key: 'fake_follow_up_trigger', value: 'ON Level 0'}
      super

  @updateTelescopeStatus: ->
    $.getJSON '/telescope_status.json', (status) ->
      current_status = Telescope.findByAttribute 'key', 'telescope_status'

      if _.isNull current_status
        Telescope.create {key: 'telescope_status', value: status}
      else
        Telescope.update current_status.id, {value: status}

      Spine.trigger 'telescope_status'

  @updateTelescopeStatusChangeTime: (data) ->
    
    if parseInt(data) == 0
      timeStr = 'waiting'
      dateStr = 'for update...'
    else
      date = new Date( parseInt(data) ).toString().split(' ')
      dateStr = date[0] + ' ' + date[1] + ' ' + date[2]
      timeStr = date[4][0..4] + ' ' + date[6][1..3]
      
    tempTime = Telescope.findByAttribute 'key', 'telescope_status_change_time'
    tempDate = Telescope.findByAttribute 'key', 'telescope_status_change_date'
    
    if _.isNull tempTime
      Telescope.create {key: 'telescope_status_change_time', value: timeStr}
    else
      Telescope.update tempTime.id, {value: timeStr}
      
    if _.isNull tempDate
      Telescope.create {key: 'telescope_status_change_date', value: dateStr}
    else
      Telescope.update tempDate.id, {value: dateStr}

    Spine.trigger 'status_change_time'

  updateNewData: ->
    $.getJSON '/time_to_new_data.json', (status) ->
      current_time = Telescope.findByAttribute 'key', 'time_to_new_data'

      if _.isNull current_time
        Telescope.create {key: 'time_to_new_data', value: status.ttl}
      else
        if status.ttl > 0
          Telescope.update current_time.id, {value: status.ttl}

      Spine.trigger 'time_to_new_data'

  updateFollowup: ->
    $.getJSON '/time_to_followup.json', (status) ->
      current_time = Telescope.findByAttribute 'key', 'time_to_followup'

      if _.isNull current_time
        Telescope.create {key: 'time_to_followup', value: status.ttl}
      else
        if status.ttl > 0
          Telescope.update current_time.id, {value: status.ttl}

      Spine.trigger 'time_to_followup'
      
  countdown: =>
    if @value < 1 then return
    @timer = window.setInterval @tick, 1000

  tick: =>
    @value -= 1
    if @value < 1 then clearInterval @timer


window.Telescope = Telescope