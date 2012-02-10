class TargetsSlide extends Spine.Controller 
  events:
    'dot #click' : 'selectTarget'

  constructor:->
    @current_tartget= @targets[0]
    @render()

  render:=>
    @html @view('targets_slide_show')
  
window.TargetsSlide = TargetsSlide
