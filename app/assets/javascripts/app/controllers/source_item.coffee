#= require ./sources

class SourceItem extends Spine.Controller
  elements:
    '#star_vis': "visualization"

  events:
    'click #back_button': 'goBack'
    'click #planethunters_button': 'openPlanetHunters'
    'click #talk_button': 'openTalk'
    
  constructor: (params) ->
    super

  active: (params) ->
    super
    @source_id = params.id

    if Source.count() == 0
      Source.fetch(@setupSource)
    else
      @setupSource()

  render: =>
    @html @view('sources/source_details')(@source)
    new SystemViewer({el: @visualization, source: @source})

  setupSource: =>
    @source = Source.find @source_id
    @render()

  # Events
  goBack: (e) ->
    @navigate '/sources'

  openPlanetHunters: =>
    window.open @source.planetHuntersLink(), '_newtab'

  openTalk: =>
    window.open @source.talkLink(), '_newtab'

window.SourceItem = SourceItem
