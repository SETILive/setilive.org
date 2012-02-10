class TargetsSlide extends Spine.Controller 

  events:
    'click .dot' : 'selectTarget'

  constructor:(args)->
    super
    @targets = args.targets 
    @current_target= @targets[0]
    @render()

  render:=>
    @html @view('targets_slide_show')
      targets : @targets
      current_target : @current_target

  selectTarget:(e)=>
    targetId = $(e.currentTarget).data().id 
    @currentTarget = (target for target in @targets when target.id == targetId)
    @render()
    
window.TargetsSlide = TargetsSlide
