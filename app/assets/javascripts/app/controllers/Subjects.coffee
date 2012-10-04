
class Subjects extends Spine.Controller
  elements: 
    ".name": "name"
    "#main-waterfall": "main_beam"
    ".small-waterfall": "sub_beams"
    ".waterfall": "beams"
    "#workflow": 'workflowArea'
     
  events:
    'click #main-waterfall': 'placeMarker'
    'click .small-waterfall': 'selectBeam'
    'click #close-workflow': 'closeWorkflow'
    'click .copy-beam span': 'duplicateSignalsFromObservation'
    'mouseover #main-waterfall': 'mainMouseOver'
    'mouseleave #main-waterfall': 'mainMouseLeave'

  canDrawSignal: true
  dragging: false
  stage: 0
  current_beam: 0
    
  constructor: ->
    super
    Subject.bind 'create', @render
    Subject.bind('done', @saveClassification)

    Spine.bind 'nextBeam', @nextBeam
    Spine.bind 'clearSignals', @deleteAllSignals
    Workflow.bind 'workflowDone', @enableSignalDraw
    Workflow.bind 'workflowDone', @finalizeSignal
    
    @showSimulation = false
    @simBeam = 0

    Spine.bind 'doneClassification', @saveClassification

  render: (subject) =>
    @current_subject = subject
    @html @view('waterfalls')(@current_subject.observations)
    
    @current_classification = new Classification 
      subject_id: @current_subject.id
      start_time: new Date()

    # Reset current beam
    @current_beam = 0
    @enableSignalDraw()

    @setUpBeams()

    $(document).keydown (e) =>
      switch e.keyCode
        when 39 then @nextBeam()
        when 37 then @previousBeam()

  setUpBeams: =>
    @wrapBeams()
    @drawBeam $(beam).find("canvas"), @current_subject, index for beam, index in @sub_beams
    
    @selectBeam @current_beam

  #drawing methods for the beams 
  wrapBeams: =>
    @overlays = (Raphael($(beam).attr("id"), '100%', '100%') for beam in @beams)
    $(overlay.canvas).css("z-index","10000") for overlay in @overlays 
    new Workflows({el: $(@workflowArea)})

  selectBeam: (beamNo) =>
    if typeof beamNo == 'object'
      beamNo.preventDefault()
      beamNo = $(beamNo.currentTarget).data().id 

    unless @current_beam == beamNo
      $("#main-waterfall .signal_beam_#{@current_beam}").hide()
      $("#main-waterfall path").hide()

    @current_beam = beamNo

    $(".waterfall").removeClass("selected_beam")
    $(".small-waterfall-container .copy-beam").empty()

    # Get observations that have signals that aren't the current observation
    otherObservationsWithSignals = _.filter @current_subject.observations, (observation) =>
      unless observation.id == @current_subject.observations[@current_beam].id
        if @current_classification.signals().findAllByAttribute('observation_id', observation.id).length
          return true
      return false

    # Prepare waterfall area for newly selected beam
    if otherObservationsWithSignals.length
      beamNumbers = _.pluck otherObservationsWithSignals, 'beam_no'
      $("#waterfall-#{@current_beam}").siblings('.copy-beam').html @view('waterfalls_copy_text')({sources: beamNumbers, destination: @current_beam})

    $("#waterfall-#{@current_beam}").addClass("selected_beam")
    @drawBeam @main_beam.find("canvas"), @current_subject, @current_beam
    $("#main-waterfall .signal_beam_#{@current_beam}").show()

    Spine.trigger "beamChange"
      observation: @current_subject.observations[beamNo]
      beamNo: beamNo
      totalBeams: @current_subject.observations.length

  nextBeam: =>
    if @current_beam < @current_subject.observations.length - 1
      @selectBeam @current_beam + 1

  previousBeam: =>
    unless @current_beam < 1
      @selectBeam @current_beam - 1

  duplicateSignalsFromObservation: (e) =>
    # grab source and destination
    source = $(e.currentTarget).data('source')
    destination = $(e.currentTarget).data('destination')

    # Get observation id for the source and destination observations
    source_observation_id = @current_subject.observations[source].id
    destination_observation_id = @current_subject.observations[destination].id

    # Destroy all existing signals at the destionation beam
    _.each @current_classification.signals().findAllByAttribute('observation_id', destination_observation_id), (signal) =>
      $(".signal_#{signal.id}").remove()
      signal.destroy()

    # Get all signals that belong to the source observation id
    source_signals = @current_classification.signals().findAllByAttribute('observation_id', source_observation_id)

    # Change source signals' observation id to destination's observation id and save it
    _.each source_signals, (signal) =>
      new_signal = signal.dup()
      new_signal.characterisations = signal.characterisations # Move characterisations to the new signal
      new_signal.updateAttribute 'observation_id', destination_observation_id

      # Series of horrible hacks to generate visual signal
      @drawLine new_signal
      @drawIndicator new_signal.freqStart, new_signal.timeStart, new_signal
      @drawIndicator new_signal.freqEnd, new_signal.timeEnd, new_signal
      @finalizeSignal new_signal

  deleteAllSignals: =>
    signal.destroy() for signal in @current_classification.signals().all()
    $(".signal").remove()

  finalizeSignal: (new_signal = false) =>
    # Default to currentSignal unless a specific signal is passed
    unless new_signal == 'done'
      signal = new_signal
    else
      signal = @current_classification.currentSignal

    $(".signal_#{signal.id}.signal_circle").attr('opacity', '0.2')
    $(".signal_line_#{signal.id}").attr("opacity","0.2")
    $(".signal_line_#{signal.id}").attr("data-id",signal.id)
    $(".signal_#{signal.id}").removeClass("draggable")
    $(".signal").removeClass("signal_selected")
    
    $(".signal").mouseenter (e) =>
      signal_id = $(e.currentTarget).data().id
      unless $(e.currentTarget).hasClass("signal_selected")
        $(".signal_#{signal_id}").attr("opacity","1.0")
      
    $(".signal").mouseleave (e) =>
      signal_id = $(e.currentTarget).data().id
      unless $(".signal_#{signal_id}").hasClass("signal_selected")
        $(".signal_#{signal_id}").attr("opacity","0.2")

    $(".signal_#{signal.id}").click (e) =>
      e.stopPropagation()
      signal_id = $(e.currentTarget).data().id
      @current_classification.setSignal(signal_id)
      unless $(".signal_#{signal_id}").hasClass("signal_selected")
        @dissableSignalDraw()
        $(".signal_#{signal_id}").attr("opacity","1.0")
        $(".signal_#{signal_id}").addClass("signal_selected")
        $(".signal_#{signal.id}.signal_circle").addClass("draggable")
        Spine.trigger("startWorkflow", signal)

  closeWorkflow: (e) =>
    e.stopPropagation()
    @finalizeSignal @current_classification.currentSignal
    @enableSignalDraw()
    Spine.trigger 'closeWorkflow'

  enableSignalDraw: =>
    @canDrawSignal = true 

  dissableSignalDraw: =>
    @canDrawSignal = false
    
  drawBeam: (target,subject,beamNo) ->
    ctx = target[0].getContext('2d')

    targetWidth = $(target[0]).width()
    targetHeight = $(target[0]).height()
    target[0].width = targetWidth
    target[0].height = targetHeight
    
    if subject.observations[beamNo].uploaded 
      obsImg = new Image targetWidth, targetHeight
      unless subject.observations[beamNo].has_simulation
        obsImg.src = subject.observations[beamNo].image_url
      else
        if @showSimulation
          obsImg.src = subject.observations[beamNo].simulation_reveal_url
        else 
          obsImg.src = subject.observations[beamNo].simulation_url

      $(obsImg).load =>
        ctx.drawImage obsImg, 0, 0, targetWidth,targetHeight
    else
      imageData = ctx.getImageData(0,0,targetWidth,targetHeight)
      data = subject.imageDataForBeam(beamNo,targetWidth,targetHeight)
      imageData.data[i]=data[i] for i in [0..data.length]
      ctx.putImageData(imageData,0,0)


  drawCombinedBeam: (target,subject) ->
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
  placeMarker: (e) =>
    console.log $(e.currentTarget)
    console.log @canDrawSignal
    console.log @dragging
    if @canDrawSignal and not @dragging
      dx  = (e.pageX * 1.0 - $(e.currentTarget).offset().left) / @main_beam.width()*1.0
      dy  = (e.pageY * 1.0 - $(e.currentTarget).offset().top) / @main_beam.height()*1.0
        
      if @stage is 0
        signal = @current_classification.newSignal(dx, dy, @current_subject.observations[@current_beam].id )
      else 
        @current_classification.updateSignal(dx,dy)

      @drawIndicator(dx,dy)
  
  drawIndicator: (x, y, new_signal = false) =>
    if new_signal
      signal = new_signal
    else
      signal = @current_classification.currentSignal

    for beam in [@overlays[0]]
      canvas = $(beam.canvas)
      radius = canvas.parent().height() * 0.017

      window.clickcanvas = canvas

      circle = beam.circle(x * canvas.parent().width(), y * canvas.parent().height(), radius)
      circle.attr
        "stroke": "#CDDC28"
        "stroke-width": "2"
        "fill": "purple"
        "fill-opacity": "1"

      self = this
      circle.toFront()
      circle.drag(
       (x,y) ->
          if $(this.node).hasClass("draggable")
            this.attr
              cx: this.startX + x
              cy: this.startY + y 
            if $(this.node).hasClass("stage_0")
              signal.updateAttributes 
                "freqStart": this.attr("cx") / canvas.parent().width()
                "timeStart": this.attr("cy") / canvas.parent().height()
            else 
              signal.updateAttributes 
                "freqEnd": this.attr("cx") / canvas.parent().width()
                "timeEnd": this.attr("cy") / canvas.parent().height()
            self.updateLine(signal)
       , ->
          if $(this.node).hasClass("draggable")
            this.startX = this.attr("cx")
            this.startY = this.attr("cy")
        )

      $(circle.node).addClass("signal")
      $(circle.node).addClass("signal_selected")
      $(circle.node).addClass("signal_circle")
      $(circle.node).attr("data-id", signal.id)

      $(circle.node).addClass("signal_#{signal.id}")

      if $(".signal_circle.signal_#{signal.id}.stage_0").length
        $(circle.node).addClass("stage_1")
        $(circle.node).addClass("draggable")
      else
        $(circle.node).addClass("stage_0")

      $(circle.node).addClass("signal_beam_#{@current_beam}")

    unless new_signal
      @stage += 1 
      if @stage == 2 
        @drawLine(signal)
        @enableSignalDraw()
        Spine.trigger 'startWorkflow', signal
  
  updateLine: (signal) =>
    $(".signal_line_#{signal.id}").remove()
    @drawLine(signal)

  drawLine: (signal) =>
    for beam in [@overlays[0], @overlays[@current_beam + 1]]
      canvas = $(beam.canvas)
      startY = signal.interp(0) * canvas.parent().height()
      endY   = signal.interp(1) * canvas.parent().height()
      startX = 0
      endX   = canvas.parent().width()

      unless isFinite startY
        startY = 0
        endY = canvas.parent().height()
        startX = signal.freqStart * canvas.parent().width()
        endX = startX

      line  = beam.path("M#{startX},#{startY}l#{endX-startX},#{endY-startY}z").toBack()

      line.attr
        stroke: "#CDDC28"
        "stroke-width"   : 2
        "stroke-opacity" : 1

      $(line.node).addClass("signal")
      $(line.node).addClass("signal_#{signal.id}")
      $(line.node).addClass("signal_line_#{signal.id}")
      $(line.node).addClass("signal_selected")
      $(line.node).addClass("signal_beam_#{@current_beam}")

    @stage = 0

  saveClassification: =>
    if @current_subject.has_simulation
      @showSimulation = true
      for observation, index in @current_subject.observations
        if observation.has_simulation
          @selectBeam index
          @simBeam = index

    @current_classification.persist() unless window.tutorial

  mainMouseOver: =>
    if @showSimulation && @current_beam == @simBeam
      target = @main_beam.find("canvas")
      subject = @current_subject
      beamNo = @current_beam
      ctx = target[0].getContext('2d')

      targetWidth = $(target[0]).width()
      targetHeight = $(target[0]).height()
      target[0].width = targetWidth
      target[0].height = targetHeight
      obsImg = new Image targetWidth, targetHeight
      obsImg.src = subject.observations[beamNo].simulation_url
      $(obsImg).load =>
        ctx.drawImage obsImg, 0, 0, targetWidth,targetHeight

  mainMouseLeave: =>
    if @showSimulation && @current_beam == @simBeam
      target = @main_beam.find("canvas")
      subject = @current_subject
      beamNo = @current_beam
      ctx = target[0].getContext('2d')

      targetWidth = $(target[0]).width()
      targetHeight = $(target[0]).height()
      target[0].width = targetWidth
      target[0].height = targetHeight
      obsImg = new Image targetWidth, targetHeight
      obsImg.src = subject.observations[beamNo].simulation_reveal_url
      $(obsImg).load =>
        ctx.drawImage obsImg, 0, 0, targetWidth,targetHeight


window.Subjects = Subjects