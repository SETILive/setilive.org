
class Stats extends Spine.Controller

    
  constructor: ->
    super 
    $.getJSON '/stats.json',(data) =>
      console.log "getting data"
      @render(data)

    Spine.bind 'updateStats', @render
      

  render:(stats)=>
    console.log("updating stats",stats)
    @html @view('global_stats')(stats)

window.Stats = Stats

