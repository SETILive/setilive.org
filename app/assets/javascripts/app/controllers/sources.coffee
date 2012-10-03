
class Sources extends Spine.Controller
  elements:
    '#sources': 'sources_list'

  events:
    'click .page_link': 'selectPage'
    'click .source': 'selectSource'

  perPage: 12

  constructor: (params) ->
    super
    @page = params.page or 0

  render: =>
    @html @view 'sources/sources'

    if Source.count() == 0
      Source.fetch(@changePage)
    else
      @changePage @page

  active: ->
    super
    @render()

  deactivate: ->
    super
    @el.html ''

  changePage: (page = 0) =>
    sources = Source.kepler_planets()
    @page = page
    @pages = sources.length / @perPage

    @sources_list.html @view('sources/sources_list')({
        page: @page
        pages: @pages
        perPage: @perPage
        sources: sources
      })

  selectPage: (e) =>
    e.preventDefault()
    @changePage $(e.currentTarget).data 'id'

  selectSource: (e) =>
    source_id = $(e.currentTarget).data 'id'
    @navigate '/sources', source_id

window.Sources = Sources



    