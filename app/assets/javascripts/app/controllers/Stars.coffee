
class Stars extends Spine.Controller
  elements: 
    "#field" : "field"
    ".star"  : "stars"
  
  constructor: ->
    super
    @paper = Raphael("star_field_small","100%","100%")
    @indicators={}
    @calcBounds()
    @colors = ['red', 'yellow', 'green']

  updateTarget: (data) ->

  drawField:=>
    
    obss = Subject.last().observations
    @current_indicators = [null, null, null]
    for obs,index in obss
      if obs.source.coords[0]? and obs.source.coords[1]?
        @current_indicators[index] = obs.source
        @drawStar( obs.source, @colors[index] )
        @drawIndicator( index, @colors[index] )
    
    Spine.bind "update_indicators",(data)=>
      @current_indicators[data.beamNo] = data.source
    
  calcBounds:->
    @center = [290.667, 44.5] # degrees <= 19:22:40 +44:30:00
    
    # Pixel size in tangent-projected RA and DEC degrees (I think this is
    # correct.
    # A fudge factor of 1.05 is included for empirical image scaling error
    # The image is also not rotated properly, but this is not corrected.
    @dXdR =  ( @el.width() / 2.0 ) / ( Math.tan( ( Math.PI / 180.0 ) * 
             ( 35.25477 * 1.05 ) / 2.0 ) * ( 180.0 / Math.PI ) )
    @dYdD = ( @el.height() / 2.0 ) / ( Math.tan( ( Math.PI / 180.0 ) * 
             ( 23.32797 * 1.05 ) / 2.0 ) * ( 180.0 / Math.PI ) )

  convertRaDec:(pos)->
    ra_pixels  = @el.width() / 2.0 - ( pos[0] - @center[0] ) * @dXdR
    dec_pixels = @el.height() / 2.0 - ( pos[1] - @center[1] ) * @dYdD
    [ra_pixels, dec_pixels]

  convertMag: (mag) ->
    mag / 6
  
  drawStar:(star, color)->
    unless star.coords[0] is 0 and star.coords[1] is 0
      pos = @convertRaDec(star.coords)
      mag = @convertMag(star.meta.kepler_mag)
      
      circle = @paper.circle(pos[0], pos[1], mag)
      circle.attr "fill", color

  drawIndicator: (beamNo, color) ->
    star = @current_indicators[beamNo]

    if star?
      pos = @convertRaDec(star.coords)
      mag = @convertMag(star.meta.kepler_mag)
      indicators = ( @paper.circle(pos[0], pos[1], mag) for i in [1..3])

      for indicator in indicators
        $(indicator.node).addClass("star_indicator")
      self= this

      $.each indicators, (index, indicator) =>
        indicator.attr("stroke-width","3") 
        indicator.attr("stroke", color)
        indicator.attr("opacity", 0.75)
        indicator.node.setAttribute("class", "indi")

        if index == indicators.length-1
          anim = Raphael.animation {"r":"20", "stroke-opacity":"0", "stroke-width":0}, 1000, =>
            indicator.remove()
            setTimeout (=>self.drawIndicator(beamNo,color)), 1000
        else
          anim = Raphael.animation {"r":"20", "stroke-opacity":"0", "stroke-width":0}, 1000, =>
            indicator.remove()

        indicator.animate anim.delay(index*200)


window.Stars = Stars