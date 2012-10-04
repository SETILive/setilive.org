
class Source extends Spine.Model
  @configure 'Source', 'name', 'coords', 'description', 'type', 'meta','zooniverse_id', 'seti_id'
  @extend Spine.Events

  @fetch: ->
    $.ajax
      url: 'http://zooniverse-seti-dev.s3.amazonaws.com/sourcesStatic.json',
      dataType: 'jsonp',
      jsonpCallback: 'staticSources',
      cache: true,
      success: (data) =>
        sources = []
        for source in data
          unless _.isUndefined source.meta.planets
            sources.push source
        Source.refresh sources, {clear: true}


  @find_by_seti_id: (id) ->
    @select (item) ->
      item.seti_id == id
  
  @kepler_planets: ->
    @select (item) ->
      item.type == "kepler_planet"

  kepler_no: ->
    @name.replace('kplr',"")

  planetHuntersLink: ->
    sph = @zooniverse_id.replace("TSL","SPH")
    "http://www.planethunters.org/sources/#{sph}"

  talkLink: ->
    "http://talk.setilive.org/targets/#{@zooniverse_id}"

window.Source = Source

