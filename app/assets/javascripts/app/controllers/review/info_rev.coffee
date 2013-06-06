
class InfoRev extends Spine.Controller

  elements:
    '#star_field_small': 'star_field_small'
    "#time": "time"
    "#extra_controlls": "controls"
    "#next": "next"
    "#previous": "previous"
    "#current_targets": "targets"

  events:
    'click #select': 'toggleMarkingType'
    'click #done': 'done'
    'click #next': 'next'
    'click #previous': 'previous'
    'mouseover #select': "showMarkingType"
    'mouseleave #select': "hideMarkingType"
    
  isFollowup = false
  enablePrev = false
  enableNext = false
  sources = []
  utc_date = ''
  
  
  constructor: ->
    super
    Subject.bind 'create', @render
    Spine.bind 'beamChange', @beamChange
    

  render: =>
    @subject = Subject.last() unless @subject
    @html @view('review/info_rev')(
      {subject: @subject,
      isFollowup: @isFollowup, 
      enablePrev: @enablePrev,
      enableNext: @enableNext })

  #initialSetup: =>
    #@subject = Subject.last()

    #@render()
    @controls.show()
    @previous.click(false) unless @enablePrev
    @next.click(false) unless @enableNext
    @time.addClass 'text'
    #@time.html 'Followup Review'
        
    if @subject?
      unless @sources
        #targets.push(new Source(observation.source )) if observation.source?
        for obs in @subject.observations
          @sources = sources.concat(obs.source.name.replace('kplr','Kepler ') )
          
      unless @utc_date    
        time_taken = new Date(@subject.location.time / 1000000)
        mon = '' + (time_taken.getUTCMonth() + 1)
        if mon < 10 then mon = '0' + mon
        day = time_taken.getUTCDate()
        if day < 10 then day = '0' + day
        hrs = time_taken.getUTCHours()
        if hrs < 10 then hrs = '0' + hrs
        min = time_taken.getUTCMinutes()
        if min < 10 then min = '0' + min
        sec = time_taken.getUTCSeconds()
        if sec < 10 then sec = '0' + sec

        @utc_date =
          hrs + ' : ' +
          min + ' : ' +
          sec + ' ' +
          time_taken.getUTCFullYear() + '-' +
          mon + '-' +
          day + ' UTC'
          
      @targets.html @view('classify/targets_info')
        target: @sources
        date: @utc_date
        location: @subject.location
        
      unless @stars
        @stars = new Stars(el:$("#star_field_small")) unless @stars
        @stars.drawField() #Source.fetch()
      
  toggleMarkingType: (e) =>
    Spine.trigger( 'toggleMarkingType', e )

  showMarkingType: (e) =>
    Spine.trigger( 'showMarkingType', e )

  hideMarkingType: (e) =>
    Spine.trigger( 'hideMarkingType', e )
    
  done: =>
    window.location.href = '/#/profile'
    
  next: =>
    Spine.trigger( 'nextInChain' )
    
  previous: =>
    Spine.trigger( 'prevInChain' )
    
  beamChange: (beamNo, beamIndex, chain) =>
    @isFollowup = ( beamIndex >= 0 )
    @enablePrev = false
    @enableNext = false
    if chain.length > 1 # part of chain
      @enablePrev = ( beamIndex != 0 )
      @enableNext = ( beamIndex != chain.length - 1 )
    @render()
    
  
    
window.InfoRev = InfoRev
  