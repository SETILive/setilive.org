class TargetsShow extends Spine.Controller 
  constructor : ->
    super

class TargetsIndex extends Spine.Controller 
  events:
    'click .page_link' : 'selectPage'
    'click .source'    : 'selectSource'

  perPage : 12
  constructor : -> 
    super
    @page =0
    Source.bind('refresh', @render)

  render:=>
    sources = Source.all()
    @pages = Source.count()/@perPage
    @html @view('target_index')
      page    : @page
      pages   : @pages
      perPage : @perPage
      sources : sources
    
  selectPage:(e)=>
    e.preventDefault()
    @page= $(e.currentTarget).data().id
    @render()

  selectSource:(e)=>
    window.location = "/sources/#{$(e.currentTarget).data().id}"


window.TargetsIndex = TargetsIndex
window.TargetsShow = TargetsShow