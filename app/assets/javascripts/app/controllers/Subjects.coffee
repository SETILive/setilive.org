
class Subjects extends Spine.Controller
  elements: 
    ".name" : "name"
    "#main-waterfall"  : "main_beam"
    ".small-waterfall" : "sub_beams"
    ".waterfall"       : "beams"
    "#workflow"   : 'workflowArea'
     
  events:
    'click #main-waterfall' : 'markerPlaced'
    'click .small-waterfall': 'selectBeam'

  canDrawSignal : true
  dragging : false
  stage: 0
  current_beam: 0
    
  constructor: ->
    super
    Subject.bind('create', @render)  
    Subject.bind('done', @saveClassification)

    Spine.bind("enableSignalDraw", @enableSignalDraw)
    Spine.bind("dissableSignalDraw", @dissableSignalDraw)
    Workflow.bind("workflowDone", @enableSignalDraw)
    Workflow.bind("workflowDone", @finalizeSignal)
    
    Subject.fetch()

    Spine.bind 'nextBeam', =>
      @selectBeam @current_beam+1
    
    Spine.bind 'doneClassification', @saveClassification

  render: (subject) =>
    @current_subject = subject
    @html @view('waterfalls')(@current_subject.observations)
    
    @current_classification = new Classification 
      subject_id : @current_subject.id
      start_time : new Date()
    
    @setUpBeams()
     
  selectBeam:(beamNo)=>
    if typeof beamNo == 'object'
      beamNo.preventDefault()
      beamNo = $(beamNo.currentTarget).data().id 

    $("#main-waterfall .signal_beam_#{@current_beam}").hide()

    @current_beam = beamNo
    $(".waterfall").removeClass("selected_beam")
    
    $("main-waterfall path").hide()
    $("#waterfall-#{@current_beam}").addClass("selected_beam")
    
    @drawBeam @main_beam.find("canvas"), @current_subject, @current_beam
    $("#main-waterfall .signal_beam_#{@current_beam}").show()

  enableSignalDraw :=>
    @canDrawSignal = true 

  finalizeSignal :=>
    signal = @current_classification.currentSignal
    $(".signal_#{signal.id}").attr("opacity","0.8")
    $(".signal_line_#{signal.id}").attr("opacity","0.8")
    $(".signal_#{signal.id}").removeClass("draggable")

  dissableSignalDraw :=>
    @canDrawSignal = false 

  

  getNextSubject:=>
    Subject.fetch_from_url('data/test.json')
    
  setUpBeams: =>
    @wrapBeams()           
    @current_beam or= 0
    @drawBeam $(beam).find("canvas"), @current_subject, index for beam, index in @sub_beams
    
    @selectBeam @current_beam

  
  #drawing methods for the beams 

  wrapBeams: =>
    @overlays = ( Raphael($(beam).attr("id"), '100%', '100%') for beam in @beams )
    $(overlay.canvas).css("z-index","10000") for overlay in @overlays 

    new Workflows({el:$(@workflowArea)})

  drawBeam:(target,subject,beam_no)->
    ctx = target[0].getContext('2d')
    targetWidth = $(target[0]).width()
    targetHeight = $(target[0]).height()
    target[0].width = targetWidth
    target[0].height = targetHeight
    imageData = ctx.getImageData(0,0,targetWidth,targetHeight)
    data = subject.imageDataForBeam(beam_no,targetWidth,targetHeight)
    imageData.data[i]=data[i] for i in [0..data.length]    
    ctx.putImageData(imageData,0,0)


  drawCombinedBeam:(target,subject)->
    ctx = target[0].getContext('2d')
    targetWidth = $(target[0]).width()
    targetHeight = $(target[0]).height()
    target[0].width = targetWidth
    target[0].height = targetHeight
    imageData = ctx.getImageData(0,0,targetWidth,targetHeight)
    data = subject.imageDataForCombinedBeam targetWidth,targetHeight
    imageData.data[i]=data[i] for i in [0..data.length]

    ctx.putImageData(imageData,0,0)


  
  # interaction with the beams! 
  
  markerPlaced:(e)=>
    if @canDrawSignal and not @dragging
      dx  = e.offsetX*1.0 / @main_beam.width()*1.0
      dy  = e.offsetY*1.0 / @main_beam.height()*1.0
      if(@stage==0)
        @current_classification.newSignal(dx, dy, @current_subject.observations[@current_beam].id )
      else 
        @current_classification.updateSignal(dx,dy)

      @drawIndicator(dx,dy)
  
  drawIndicator:(x,y) =>
    signal = @current_classification.currentSignal
    for beam in [@overlays[0]]
      canvas = $(beam.canvas)
      radius = canvas.height()*0.017
      circle=beam.circle(x*canvas.width(), y*canvas.height(), radius)
      circle.attr
        "stroke": "#CDDC28"
        "stroke-width":"2"
        "fill": "purple"
        "fill-opacity": "1"
        "cursor" : "move"

      self = this
      circle.drag(
       (x,y)->
          if $(this.node).hasClass("draggable")
            this.attr
              cx : this.startX+x
              cy : this.startY+y 
            if $(this.node).hasClass("stage_0")
              signal.updateAttributes 
                "freqStart" : this.attr("cx")/canvas.width()
                "timeStart" : this.attr("cy")/canvas.height()
            else 
              signal.updateAttributes 
                "freqEnd" : this.attr("cx")/canvas.width()
                "timeEnd" : this.attr("cy")/canvas.height()
            self.updateLine(signal)
       ,->
          if $(this.node).hasClass("draggable")
            this.startX= this.attr("cx")
            this.startY= this.attr("cy")
        )
        

      $(circle.node).addClass("signal_#{signal.id}")
      $(circle.node).addClass("stage_#{@stage}")
      $(circle.node).addClass("signal_beam_#{@current_beam}")
      $(circle.node).addClass("draggable")
      


    @stage += 1 
    if @stage == 2 
      @drawLine(signal) 
      @canDrawSignal = false
      Spine.trigger("startWorkflow", signal)

  

  updateLine:(signal)=>
    $(".signal_line_#{signal.id}").remove()
    @drawLine(signal)

  drawLine:(signal)=>
    for beam in [@overlays[0], @overlays[@current_beam+1]] 
      canvas = $(beam.canvas)
      startY = signal.interp(0) * canvas.height()
      endY   = signal.interp(1) * canvas.height()
      startX = 0
      endX   = canvas.width()
      
      line  = beam.path("M#{startX},#{startY}l#{endX-startX},#{endY-startY}z")
      line.attr
        stroke : "#CDDC28"
        "stroke-width"   : 2
        "stroke-opacity" : 1
      $(line.node).addClass("signal_line_#{signal.id}")
      $(line.node).addClass("signal_beam_#{@current_beam}")

    @stage=0
    
  saveClassification:=>
    @current_classification.persist()

window.Subjects = Subjects