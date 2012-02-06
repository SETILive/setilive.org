
class Stats extends Spine.Controller
  elements: 
    ".people-online" : "peopleOnline"
    ".total-classifications" : "totalClassifications"
    ".daily-classifications" : "dailyClassifications"
    ".classification-rate" : "rate"
    
  constructor: ->
    super 
    setInterval @updateStats, 2000 if @el[0]
  
  updateStats:=>
    @peopleOnline.html( @peopleOnline.html()*1.0 + Math.floor((Math.random()*20 -10)))
    @totalClassifications.html( @totalClassifications.html().replace(/\D/g,"")*1.0 + 1)
    @dailyClassifications.html( @dailyClassifications.html().replace(/\D/g,"")*1.0 + 1)
    @rate.html( @rate.html().replace(/\D/g,"")*1.0 + Math.floor((Math.random()*20 -10))+" <span class='mins'>/min</span> ")

window.Stats = Stats