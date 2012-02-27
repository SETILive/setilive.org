
class Source extends Spine.Model
  @configure 'Source', 'name', 'coords', 'description', 'type', 'meta','zooniverse_id', 'seti_id'
  @extend Spine.Events


  @fetch:->
    $.getJSON '/sources.json', (data)=>
      Source.create(source) for source in data
      Source.trigger('refresh',Source.all())

  @find_by_seti_id:(id)->
    @select (item) ->
      item.seti_id==id
  
  @kepler_planets:->
    @select (item) ->
      item.type=="kepler_planet"

  kepler_no:->
    @name.replace('kplr',"")

  planetHuntersLink :->
    sph = @zooniverse_id.replace("TSL","SPH")
    "http://www.planethunters.org/sources/#{sph}"

  talkLink :->
    "http://talk.setilive.org/targets/#{@zooniverse_id}"

window.Source = Source

