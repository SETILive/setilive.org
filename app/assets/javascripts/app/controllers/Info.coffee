
class Info extends Spine.Controller
  elements:
    "#time" : "time"
    "#extra_controlls" : "controls"
    "#done_talk" : "doneTalk"
    "#current_targets" : "targets"
    "#next_beam" : "nextBeam"

  events:
    "click #done " : "done"
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
    Source.bind('refresh', @setupTargets)

  setupTargets:() =>
    subject = Subject.first()
    sources  = Source.all()
    if subject?  and sources.length > 0
      # target_ids = ( targets for targets in subject.beam ) 
      targets    = [sources[33],sources[44]] 
      new TargetsSlide(el:@targets , targets: targets)


  updateTime:=>
    timeRemaining = (@targetTime - Date.now())/1000
    mins          = Math.floor timeRemaining/60
    secs          = Math.floor timeRemaining-mins*60
    @time.html "#{if mins<10 then "0" else ""}#{mins}:#{if secs<10 then "0"  else ""}#{secs}"
    @resetTime() if timeRemaining <= 0
    
  resetTime:=>
    @targetTime = (1).minutes().fromNow()

  done :=>
    Spine.trigger "dissableSignalDraw" 
    @doneTalk.html @view("talk_prompt")()

  talk :=>
    window.open 'http://talk.setilive.org'
    Subject.trigger "done"

  dontTalk :(e)=>
    Subject.trigger "done"    
  
  favourite:=>
    u= User.first()
    u.addFavourite Subject.first

  nextBeam:=>
    @nextBeam.replaceWith("<div class='extra_button' id='done'>Done</div>")
    
window.Info = Info
  