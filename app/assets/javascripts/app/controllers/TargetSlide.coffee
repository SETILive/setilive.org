class TargetsSlide extends Spine.Controller 

  events:
    'click .dot' : 'selectTarget'
    'click #target': 'showTarget'

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
    @current_target = (target for target in @targets when target.id == targetId)[0]
    @render()

  showTarget:(e)=>
    window.open("/sources/#{@current_target.id}")
window.TargetsSlide = TargetsSlide
