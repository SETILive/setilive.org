
class Stats extends Spine.Controller

    
  constructor: ->
    super 
    @updateStats()
    
  updateStats:=>
    $.getJSON '/stats.json',(data) =>
      @render(data)
      

  render:(stats)=>
    @html @view('global_stats')(stats)

window.Stats = Stats

