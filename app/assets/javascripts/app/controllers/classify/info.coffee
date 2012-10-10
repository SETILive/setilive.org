
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
    "click #talkYes": "talk"
    "click #talkNo": "dontTalk"
    "click #favourite": "favourite"
    "click #next_beam": "nextBeam"
    "click #clear_signal": "clearSignals"

  constructor: ->
    super
    @render()
    Subject.bind 'create', @initialSetup
    Spine.bind 'beamChange', @beamChange

  render: =>
    @html @view 'classify/info'

  initialSetup: =>
    # Make sure info shown is default
    @resetTime()
    @controls.show()
    @talk.hide()
    @social.empty()
    @simulation_notification.hide()
    @talk_fill.hide()
    @thankyou.hide()

    if Subject.first().subjectType == 'new' or window.tutorial == true
      @timeInterval = setInterval @updateTime, 100
    else
      @time.addClass 'text'
      @time.html 'Archive Data'

    subject = Subject.first()
    if subject.observations.count == 1 
      @done.show()
      @nextBeam.hide() 
    if subject?
      targets = []
      for observation in subject.observations
        targets.push(new Source(observation.source )) if observation.source?

      @targets.html @view('classify/targets_info')
        location: subject.location

  clearSignals: =>
    Spine.trigger 'clearSignals'

  updateTime: =>
    timeRemaining = (@targetTime - Date.now())/1000
    mins          = Math.floor timeRemaining/60
    secs          = Math.floor timeRemaining-mins*60
    @time.html "#{if mins<10 then "0" else ""}#{mins}:#{if secs<10 then "0"  else ""}#{secs}"
    if timeRemaining <= 0
      clearInterval @timeInterval
      @time.addClass 'text'
      @time.html 'Time expired!'

  resetTime: =>
    @time.removeClass 'text'
    @targetTime = (1).minutes().fromNow()

  doneClassification: =>
    @controls.hide()
    @talk.before '<p>Saving...</p>'

    Classification.bind 'classificationSaved', =>
      Classification.unbind 'classificationSaved'

      @talk.prev().remove()
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
    

  talk: =>
    subject = Subject.first()
    window.open subject.talkURL()
    $.getJSON "/register_talk_click", =>
      Subject.fetch_next_for_user()

  dontTalk: (e) =>
    Subject.fetch_next_for_user()

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
  