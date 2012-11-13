
class Info extends Spine.Controller

  elements:
    '#star_field_small': 'star_field_small'
    "#time": "time"
    "#extra_controlls": "controls"
    "#done": "done"
    "#current_targets": "targets"
    "#next_beam": "nextBeam"
    "#talk": "talk"
    "#simulation_notification": "simulation_notification"
    "#thankyou": "thankyou"
    "#talk_fill": "talk_fill"
    "#social": "social"

  events:
    "click #done": "doneClassification"
    "click #talkYes": "getNextSubject"
    "click #talkNo": "getNextSubject"
    "click #favourite": "favourite"
    "click #next_beam": "nextBeam"
    "click #clear_signal": "clearSignals"

  constructor: ->
    super
    Subject.bind 'create', @initialSetup
    Spine.bind 'beamChange', @beamChange

  render: (subject) =>
    @html @view('classify/info')({subject: subject})

  initialSetup: =>
    subject = Subject.last()

    # Make sure info shown is default
    @render subject
    #@resetTime()
    @controls.show()
    @social.hide()
    @talk.hide()
    @simulation_notification.hide()
    @talk_fill.hide()
    @thankyou.hide()

    #@social.append @view('classify/facebookWaterfall')
    #  subject: Subject.first()

    #@social.append @view('classify/twitterWaterfall')
    #  subject: Subject.first()
      
    @talk.children('.extra_button').removeAttr 'disabled'
    @talk.find('[data-action="talk-no"]').html 'No'

    @telescope_status = Telescope.findByAttribute('key','telescope_status')
    if subject.subjectType == 'new' or window.tutorial == true
      #@timeInterval = setInterval @updateTime, 100
      $.getJSON '/user_live_stats.json', (data) =>
        total = parseInt(data.seen,10) + parseInt(data.unseen,10) + 1
        @time.addClass 'text'
        @time.html "#{data.seen} of #{total} Classified!"
    else
      @time.addClass 'text'
      if @telescope_status.value is 'active' or @telescope_status.value is 'replay'
        @time.html 'Archive Data'
      else
        @time.html 'Archive Data'
        

    if subject.observations.count == 1
      @done.show()
      @nextBeam.hide()
    if subject?
      sources = []
      #targets.push(new Source(observation.source )) if observation.source?
      for obs in subject.observations
        sources = sources.concat(obs.source.name.replace('kplr','Kepler ') )       
      time_taken = new Date(subject.location.time / 1000000)
      mon = '' + (time_taken.getUTCMonth() + 1)
      if mon < 10 then mon = '0' + mon
      day = time_taken.getUTCDate()
      if day < 10 then day = '0' + day
      hrs = time_taken.getUTCHours()
      if hrs < 10 then hrs = '0' + hrs
      min = time_taken.getUTCMinutes()
      if min < 10 then min = '0' + min
      sec = time_taken.getUTCSeconds()
      if sec < 10 then sec = '0' + sec

      utc_date =
        hrs + ' : ' +
        min + ' : ' +
        sec + ' ' +
        time_taken.getUTCFullYear() + '-' +
        mon + '-' +
        day + ' UTC'
        
      @targets.html @view('classify/targets_info')
        target: sources
        date: utc_date
        location: subject.location
        
      @stars = new Stars(el:$("#star_field_small"))
      @stars.drawField() #Source.fetch()

  clearSignals: =>
    Spine.trigger 'clearSignals'

#  updateTime: =>
#    timeRemaining = (@targetTime - Date.now())/1000
#    mins          = Math.floor timeRemaining/60
#    secs          = Math.floor timeRemaining-mins*60
#    @time.html "#{if mins<10 then "0" else ""}#{mins}:#{if secs<10 then "0"  else ""}#{secs}"
#    if timeRemaining <= 0
#      clearInterval @timeInterval
#      @time.html '00:00'

#  resetTime: =>
#    @time.removeClass 'text'
#    @targetTime = (0.5).minutes().fromNow()

  doneClassification: =>
    @controls.hide()
    @social.show()
    @talk.show()
    
    @social.append @view('classify/facebookWaterfall')
      subject: Subject.first()

    @social.append @view('classify/twitterWaterfall')
      subject: Subject.first()

    if Subject.first().has_simulation
      @simulation_notification.show() 
    else
      @talk_fill.show()
      @thankyou.show()

    Spine.trigger 'dissableSignalDraw' 
    Spine.trigger 'doneClassification'
    
  getNextSubject: (e) =>
    clearInterval @timeInterval
    action = $(e.currentTarget).data 'action'

    switch action
      when 'talk-yes'
        subject = Subject.first()
        #window.open subject.talkURL()
        #$.getJSON '/register_talk_click'

    unless @talk.children('.extra_button').attr('disabled') is 'disabled'
      Subject.fetch_next_for_user()
    @talk.children('.extra_button').attr 'disabled', 'disabled'
    @talk.find('[data-action="talk-no"]').html 'Loading...'

  favourite: (e) =>
    unless $(e.currentTarget).hasClass('favourited')
      u = User.first()
      for observation in Subject.first().observations
        u.addFavourite observation.id 
      $(e.currentTarget).html("<span style='color:white'>✓</span>")
      $(e.currentTarget).addClass('favourited')
      User.trigger("favourited")
  
  nextBeam: =>
    Spine.trigger("nextBeam")

  beamChange: (data) =>
    if data.beamNo == data.totalBeams-1
      @done.show()
      @nextBeam.hide() 
    else
      @done.hide()
      @nextBeam.show()
      

window.Info = Info
  