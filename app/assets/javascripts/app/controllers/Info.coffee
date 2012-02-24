
class Info extends Spine.Controller
  elements:
    "#time" : "time"
    "#extra_controlls" : "controls"
    "#done" : "done"
    "#current_targets" : "targets"
    "#next_beam" : "nextBeam"

  events:
    "click #done " : "doneClassification"
    "click #talk_yes" : "talk"
    "click #talk_no" : "dontTalk"
    "click #favourite" : "favourite"
    "click #next_beam" : "nextBeam"
    "click #clear_signal" : "clearSignals"
    

  constructor: ->
    super
    @resetTime()
    setInterval @updateTime, 100
    Subject.bind('create', @setupTargets)

  setupTargets:() =>
    subject = Subject.first()
    if subject?  and Source.count() > 0
      # target_ids = ( targets for targets in subject.beam ) 
      targets = []
      for observation in subject.observations
        source = Source.find(observation.source_id)
        targets.push(source ) if source?
      new TargetsSlide(el:@targets , targets: targets)


  updateTime:=>
    timeRemaining = (@targetTime - Date.now())/1000
    mins          = Math.floor timeRemaining/60
    secs          = Math.floor timeRemaining-mins*60
    @time.html "#{if mins<10 then "0" else ""}#{mins}:#{if secs<10 then "0"  else ""}#{secs}"
    @resetTime() if timeRemaining <= 0
    
  resetTime:=>
    @targetTime = (1).minutes().fromNow()

  doneClassification :=>
    Spine.trigger "dissableSignalDraw" 
    Spine.trigger 'doneClassification'
    console.log "rendering talk prompt "
    # console.log   @view("talk_prompt")()
    # console.log   @done
    # @done.replaceWith( @view("talk_prompt")())

  talk :=>
    window.open 'http://talk.setilive.org'
    Subject.trigger "done"

  dontTalk :(e)=>
    Subject.trigger "done"    
  
  favourite:(e)=>
    unless $(e.currentTarget).hasClass('favourited')
      u= User.first()
      for observation in Subject.first().observations
        u.addFavourite observation.id 
      $(e.currentTarget).html("<span style='color:white'>✓</span>")
      $(e.currentTarget).addClass('favourited')
  nextBeam:=>
    @nextBeam.replaceWith("<div class='extra_button' id='done'>Done</div>")
    Spine.trigger("nextBeam")

window.Info = Info
  