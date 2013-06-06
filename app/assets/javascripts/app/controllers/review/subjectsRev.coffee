
class SubjectsRev extends Spine.Controller
  elements: 
    ".name": "name"
    "#main-waterfall": "main_beam"
    ".small-waterfall": "sub_beams"
    ".waterfall": "beams"
    "#workflow": 'workflowArea'
     
  events:
    'click .small-waterfall': 'selectBeam'

  current_beam: 0
  current_chain: []
  current_chain_index: -1
   
  constructor: ->
    super
    Subject.bind 'create', @render
    Spine.bind 'toggleMarkingType', @toggleMarkingType
    Spine.bind 'showMarkingType', @showMarkingType
    Spine.bind 'hideMarkingType', @hideMarkingType
    Spine.bind 'nextInChain', @nextInChain
    Spine.bind 'prevInChain', @prevInChain
    
    @userMarks = false
    @followupSignal = false
    @otherMarks = false
    @holdShow = false
    @markingType = ''

  render: (subject) =>
    subject = @current_subject unless subject
    @current_subject = subject
    @setBeam( @current_beam )
    Spine.trigger( 'beamChange', @current_beam, @current_chain_index, @current_chain )
    @html @view('review/waterfalls_rev')(
         current_beam: @current_beam
         observations: @current_subject.observations)
    $("#waterfall-#{@current_beam}").addClass("selected_beam")
    
    @drawMarkings()
    
  setBeam: (beamNo) =>
    @current_beam = beamNo
    # set followup chain for currently selected beam if there's more than one
    # followup observation
    length = @current_subject['followupObs'].length
    if length >> 1
      @current_chain = @current_subject['observations'][@current_beam]['followupObs'] 
      @current_chain_index = 
              @current_chain.indexOf(@current_subject['observations'][@current_beam]['zooniverse_id'])
              
    if length == 1
      for obs in @current_subject['observations']
        @current_chain =  obs['followupObs'] if obs['followupObs'].length >> 0
      @current_chain_index = @current_chain.indexOf(@current_subject['followupObs'][0])
    
    if length == 0
      @current_chain = []
      @current_chain_index = -1


  selectBeam: (beamNo) =>
    if typeof beamNo == 'object'
      beamNo.preventDefault()
      beamNo = $(beamNo.currentTarget).data().id 
    @setBeam(beamNo)
    Spine.trigger( 'beamChange', @current_beam, @current_chain_index, @current_chain )
    @render( @current_subject )

  toggleMarkingType: (e) =>
    temp = $(e.currentTarget)[0].textContent
    if temp == 'Mine'
      @userMarks = !@userMarks
      @markingType = '' if !@userMarks && @markingType == 'userMarks'
    if temp == 'Followup'
      @followupSignal = !@followupSignal
      @markingType = '' if !@followupSignal && @markingType == 'followupSignal'
    if temp == 'Others'
      @otherMarks = !@otherMarks        
      @markingType = '' if !@otherMarks && @markingType == 'otherMarks'
    @holdShow = true # Avoid flashing with mouse movement after toggling off
    @render()
    @drawMarkings()
    
  showMarkingType: (e) => 
    unless @holdShow
      temp = $(e.currentTarget)[0].textContent      
      @markingType = 'userMarks' if temp == 'Mine'
      @markingType = 'followupSignal' if temp == 'Followup'
      @markingType = 'otherMarks' if temp == 'Others'
      @drawMarkings()
      
  hideMarkingType: (e) =>
    temp = $(e.currentTarget)[0].textContent
    @holdShow = false
    @markingType = ""
    @drawMarkings()

  drawObs: (target, index, data, thickness = 1, alpha = 1) =>
    target.hide()
    ctx = target[0].getContext('2d')
    ctx.globalAlpha = alpha
    ctx.lineWidth = thickness
    width = $(target[0]).width()
    height = $(target[0]).height()
    target[0].width = width
    target[0].height = height    
    if ( ( @markingType=='followupSignal' ) || @followupSignal ) && data.followup_id
      mid = data.followup_signal[0]
      ang = data.followup_signal[1] # Counterclockwise from "down"
      start = [mid + 0.5 * Math.tan(ang), 1]
      end = [mid - 0.5 * Math.tan(ang), 0]
      @drawLine ctx, start, end, "magenta", thickness
      
    if ( @markingType == 'userMarks' ) || @userMarks
      @drawLine ctx, line[0], line[1], "darkorange", thickness for line in data.user_signals if data.user_signals
      
    if ( @markingType == 'otherMarks' ) || @otherMarks
      @drawLine ctx, line[0], line[1], "green", thickness for line in data.other_signals if data.other_signals
  
    target.show()
    
  drawLine: (ctx, start, end, color, thickness = 1, isDashed = false ) =>
    width = ctx.canvas.width
    height = ctx.canvas.height
    ctx.strokeStyle = color
    ctx.lineWidth = thickness
    x0 = width * start[0]
    ctx.beginPath()
    ctx.moveTo( width * start[0], height * start[1] )
    ctx.lineTo( width * end[0], height * end[1] )
    ctx.stroke()    

  drawMarkings: =>
    @drawObs $(obs).find("canvas"), index, @current_subject.observations[index] for obs, index in @sub_beams
    @drawObs @main_beam.find("canvas"), 0, @current_subject.observations[@current_beam], 2
  
  nextInChain: =>
    subj = 'GSL0' + @current_chain[@current_chain_index + 1].substring(4)
    window.location.href = '/#/review/' + subj
    
  prevInChain: =>
    subj = 'GSL0' + @current_chain[@current_chain_index - 1].substring(4)
    window.location.href = '/#/review/' + subj
   
    
window.SubjectsRev = SubjectsRev