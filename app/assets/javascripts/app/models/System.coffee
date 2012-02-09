
class System extends Spine.Model
  @configure 'System', 'planets', 'kepler_id', 'ra', 'dec', 'star_type', 'spec_type', 'eff_temp', 'stellar_rad',"kepler_mag","zooniverse_id"
  
  starColors : 
    "O": "#FFFFFF"
    "B": "#FFFFFF"
    "A": "#FFFFFF"
    "F": "#FFFFDF"
    "G": "#FFFFB7"
    "K": "#FFFF9B"
    "M": "#FEB873"

  constructor: ->
    super 
    @calcLocations(0)
     
  calcLocations:(time) ->
    for planet in @planets 
      frac = (time-planet.t0)/planet.period 
      planet.x =  planet.a * Math.cos(frac*360.0)
      planet.y =  planet.a * Math.sin(frac*360.0)
    @planets 

  color :->
    @starColors[@spec_type]

     
window.System = System