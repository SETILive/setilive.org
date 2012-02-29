
class SystemViewer extends Spine.Controller

  sizeScale : 0.03
  distScale : 1
  time  : 0
  
  
  constructor:->
    super
    @expanded = false 
    @system = new System( @source.meta )
    @system.planets=@source.meta.planets 
    @render()

    setInterval @updatePlanets, 30
    
  render: ->    
    @setUpSVGTopDown()
    if @expanded
      @expand() 
      @setUpSVGProfile()

  updatePlanets: =>
    @time += 0.0009 
    @update()

  setUpSVGTopDown:->
    @context = Raphael( @el.attr("id"),  "100%", "100%" )

    @localDistScale = @distScale*@el.width()
    @localSizeScale = @sizeScale*@el.height()
    @cent_x = @el.width()/2 #@context.canvas.offsetWidth/2.0
    @cent_y = @el.height()/2 #@context.canvas.offsetWidth/2.0

    
    for planet in @system.planets
      @drawPlanet planet

    @drawStar()


  drawPlanet:(planet) ->
    r = planet.radius*@localSizeScale/5.0
    x = @cent_x + planet.x*@localDistScale
    y = @cent_y + planet.y*@localDistScale

    orbit = @context.circle @cent_x, @cent_y , planet.a*@localDistScale

    circle = @context.circle x, y, r
    
    circle.attr
      fill: "black"
      stroke:"white"
      "stroke-width": 3


    $(circle.node).attr("id","planet_#{planet.koi.replace('.','_')}")

    orbit.attr
      stroke : "white"
      "stroke-width": 3

  drawStar:(star) ->
    circle = @context.circle @cent_x, @cent_y, @system.stellar_rad*@localSizeScale
    circle.glow({color: "white", width: 30, opacity : 0.25, fill:true})
    circle.attr
      fill : "#AAAAAA"
      stroke: "white"
      "stroke-width": 3
  update: ->
    @system.calcLocations(@time)
    for planet in @system.planets 
      x = @cent_x + planet.x*@localDistScale
      y = @cent_y + planet.y*@localDistScale

      $("#planet_#{planet.koi.replace('.','_')}").attr 
        cx : x
        cy : y


window.SystemViewer = SystemViewer