class TargetsShow extends Spine.Controller 
  events:
    'click #back_button' : 'goBack'
    'click #planethunters_button' : 'openPlanetHunters'
  elements:
    '#star_vis' : "visualization"

  constructor : ->
    super
    @source_id = window.location.pathname.split("/")[2]
    Source.bind('refresh', @setupSource)

  setupSource:=>
    @source = Source.find(@source_id)
    @render()
    
  goBack:=>
    window.location = '/sources/'

  render:=>
    @html @view('target_show')(@source)
    new SystemViewer({el: @visualization, source: @source })

  openPlanetHunters:=>
    window.open(@source.planetHuntersLink(),'_newtab');


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
    sources = Source.kepler_planets()
    @pages = sources.length/@perPage
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