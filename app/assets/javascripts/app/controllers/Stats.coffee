
class Stats extends Spine.Controller

    
  constructor: ->
    super 
    # setInterval @updateStats, 2000 if @el[0]
    @render()

  render:=>
    stats=
      people_online: 10
      total_classifications: 20000
      classifications_today: 1331
      classifications_per_min: 23
        
    @html @view('global_stats')(stats)

window.Stats = Stats

