
class Source extends Spine.Model
  @configure 'Source', 'name', 'coords', 'description', 'type', 'meta'
  @extend Spine.Events

  @fetch:->
    $.getJSON '/sources.json', (data)=>
      Source.create(source) for source in data
      Source.trigger('refresh',Source.all())

  planetHuntersLink :->
    "http://www.planethunters.org/sources/#{@zooniverse_id}"

window.Source = Source

