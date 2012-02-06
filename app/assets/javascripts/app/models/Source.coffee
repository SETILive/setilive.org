
class Source extends Spine.Model
  @configure 'Source','name', 'stellar', 'kepler_id', 'zooniverse_id', 'type', 'stellar_rad', 'mag', 'ra', 'dec', 'planets'
  @extend Spine.Model.Ajax
  @extend Spine.Events

  planetHuntersLink :->
    "http://www.planethunters.org/sources/#{@zooniverse_id}"

window.Source = Source

