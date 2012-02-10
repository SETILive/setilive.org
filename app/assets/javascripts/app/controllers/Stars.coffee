
class Stars extends Spine.Controller
  elements: 
    "#field" : "field"
    ".star"  : "stars"
  
    
  constructor: ->
    super
    @paper = Raphael("star_field","100%","100%")
    Source.bind("refresh", @drawField)


  updateTarget: (data) ->
    console.log("here")
    alert(data)

  drawField:=>
    @stars = Source.all()
    
    @drawStar(star) for star in @stars 
    @drawIndicator(@stars[0],"#CDDC28")
    @drawIndicator(@stars[10],"red")
    @drawIndicator(@stars[3],"blue")
    

  calcBounds:->
    minRa  = 360
    minDec = 360
    maxRa  = 0
    maxDec = 0
    for star in @stars
      minRa  = star.coords[0] if star.coords[0] < minRa and star.coords[0]>0
      maxRa  = star.coords[0] if star.coords[0] > maxRa
      minDec = star.coords[1] if star.coords[1] < minDec and star.coords[1]>0
      maxDec = star.coords[1] if star.coords[1] > maxDec
    @bounds = [minRa, minDec, maxRa, maxDec]

  convertRaDec:(pos)->
    @calcBounds() unless @bounds?
    new_ra  = (pos[0]-@bounds[0])*@el.width()/(@bounds[2]-@bounds[0])
    new_dec = (pos[1]-@bounds[1])*@el.height()/(@bounds[3]-@bounds[1])
    [new_ra,new_dec]

  convertMag:(mag)->
    mag/6
  
  drawStar:(star)->
    unless star.coords[0] is 0 and star.coords[1] is 0
      pos = @convertRaDec(star.coords)
      mag = @convertMag(star.meta.kepler_mag)
      
      circle = @paper.circle(pos[0], pos[1], mag)
      circle.attr "fill", "white"

  drawIndicator:(star, color)->
    pos = @convertRaDec(star.coords)
    mag = @convertMag(star.meta.kepler_mag)

    indicators = ( @paper.circle(pos[0], pos[1], mag) for i in [1..3])    
    self= this

    $.each indicators, (index,indicator) =>
      indicator.attr("stroke-width","3") 
      indicator.attr("stroke", color)
      indicator.attr("opacity", 0.75)
      indicator.node.setAttribute("class", "indi")

      if index == indicators.length-1
        anim = Raphael.animation {"r":"50", "stroke-opacity":"0", "stroke-width":0}, 2000, =>
          indicator.remove()
          self.drawIndicator(star,color)
      else
        anim = Raphael.animation {"r":"50", "stroke-opacity":"0", "stroke-width":0}, 2000, =>
          indicator.remove()

      indicator.animate anim.delay(index*400)
  


window.Stars = Stars