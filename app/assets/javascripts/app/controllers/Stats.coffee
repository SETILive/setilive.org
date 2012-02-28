
class Stats extends Spine.Controller

    
  constructor: ->
    super 
    $.getJSON '/stats.json',(data) =>
      @render(data)
    Spine.bind 'updateStats', @render
      

  render:(stats)=>
    @html @view('global_stats')(stats)

window.Stats = Stats

