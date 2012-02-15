
class Stats extends Spine.Controller

    
  constructor: ->
    super 
    @updateStats()
    setInterval @updateStats, 2000 if @el[0]
    
  updateStats:=>
    $.getJSON '/stats.json',(data) =>
      @render(data)
      setInterval @updateStats, 30000
      
  render:(stats)=>
    
    @html @view('global_stats')(stats)

window.Stats = Stats

