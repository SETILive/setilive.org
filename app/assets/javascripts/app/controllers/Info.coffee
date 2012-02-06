
class Info extends Spine.Controller
  elements:
    "#time" : "time"
    "#extra_controlls" : "controls"
    "#done_talk" : "doneTalk"

  events:
    "click #done " : "done"
    "click #talk_yes" : "talk"
    "click #talk_no" : "dontTalk"

  constructor: ->
    super
    @resetTime()
    setInterval @updateTime, 100

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
    @doneTalk.html @view("views/talk_prompt")()

  talk :=>
    window.open 'http://talk.setilive.org'
    Subject.fetch()
  
  dontTalk :(e)=>
    Subject.fetch()
    
window.Info = Info
  