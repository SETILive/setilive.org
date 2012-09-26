
class Stars extends Spine.Controller
  elements: 
    "#field" : "field"
    ".star"  : "stars"
  
    
  constructor: ->
    super
    @paper = Raphael "star_field_small", "100%", "100%"
    Source.bind "refresh", @drawField 
    @indicators = {}

  updateTarget: (data) ->

  drawField: =>
    @calcBounds()
    @stars = Source.kepler_planets()
    
    for star,index in @stars 
      if index%10==0
        @drawStar(star)

    stars_with_coords = Source.select (s) =>
      s.coords[0] = parseInt s.coords[0], 10
      s.coords[1] = parseInt s.coords[1], 10

      @bounds[0] < s.coords[0] < @bounds[2] and @bounds[1] < s.coords[1] < @bounds[3]

    # @current_indicators = [stars_with_coords[2],stars_with_coords[1],stars_with_coords[10]]
    @current_indicators = _.shuffle(stars_with_coords).slice 0, 3
    console.log 'Current Indicators: ', @current_indicators

    @drawIndicator 0, "#CDDC28"
    @drawIndicator 1, "red" 
    @drawIndicator 2, "blue"

    
    Spine.bind "update_indicators",(data) =>
      @current_indicators[data.beamNo] = data.source

    
    

  calcBounds: ->
    minRa  = 360
    minDec = 360
    maxRa  = 0
    maxDec = 0
    for star in @stars

      minRa  = star.coords[0] if star.coords[0] < minRa and star.coords[0]>25
      maxRa  = star.coords[0] if star.coords[0] > maxRa
      minDec = star.coords[1] if star.coords[1] < minDec and star.coords[1]>0
      maxDec = star.coords[1] if star.coords[1] > maxDec
    

    # @bounds = [minRa, minDec, maxRa, maxDec]
    @bounds = [280.641, 37.84073829650879, 301.721, 52.1491]
  convertRaDec: (pos) ->
    @calcBounds() unless @bounds?
    new_ra  = (pos[0]-@bounds[0])*@el.width()/(@bounds[2]-@bounds[0])
    new_dec = (pos[1]-@bounds[1])*@el.height()/(@bounds[3]-@bounds[1])
    [new_ra,new_dec]

  convertMag: (mag) ->
    mag / 6
  
  drawStar: (star) ->
    unless star.coords[0] is 0 and star.coords[1] is 0
      pos = @convertRaDec(star.coords)
      mag = @convertMag(star.meta.kepler_mag)
      
      circle = @paper.circle(pos[0], (pos[1]+3), mag)
      circle.attr "fill", "white"

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
          anim = Raphael.animation {"r":"50", "stroke-opacity":"0", "stroke-width":0}, 2000, =>
            indicator.remove()
            setTimeout (=>self.drawIndicator(beamNo,color)), 2000
        else
          anim = Raphael.animation {"r":"50", "stroke-opacity":"0", "stroke-width":0}, 2000, =>
            indicator.remove()

        indicator.animate anim.delay(index*400)

  


window.Stars = Stars