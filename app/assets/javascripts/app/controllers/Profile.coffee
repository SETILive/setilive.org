
class Profile extends Spine.Controller
  inital_collection_type: 'favourites'
  
  elements:
    '.observation': 'profileObs'
  
  events:
    'click .page': 'selectPage'
    'click .collectionType': 'selectCollectionType'
    'click .markingType' : 'toggleMarkingType'
    'mouseover .markingType' : 'showMarkingType'
    'mouseleave .markingType' : 'hideMarkingType'
    'click .favourite':  'addFavourite'
    'click .favourited':  'removeFavourite'
    'click  #email_opt_img': 'toggleTelescopeNotify'
  
  constructor: ->
    super
    $("#notification_bar").show()
    @collectionType = 'favourites'
    @collectionPage = 1
    @favourites = {}
    @recents = {}
    @followups = {}
    @followupSignal = false
    @userMarks = false
    @otherMarks = false
    @markingType = ''
    @holdShow = false
    
    
    @pagination =
      page: 1
      pages: 1
      perPage: 8
      menu: ->
        JST['app/views/pagination'](@)
  
  active: ->
    super
    User.bind 'refresh', @gotUser
    $("#notification_bar").show()

    if User.count() == 0
      User.fetch_current_user()
    else
      # gotUser() Doesn't update user stats and favourites so...
      # using nuclear option, but still doesn't update favourites
      #@gotUser()
      User.fetch_current_user()
      #@gotUser()

  deactivate: ->
    super
    @el.html ''
    User.unbind 'refresh', @gotUser

  render: => 
    @html ""
    @append @view('profile/user_stats')(@user)
    
    @delay =>
      @append @view('profile/user_profile')
        user: @user
        pagination: @pagination
        subjects: @data?.collection or []
        collectionType: @collectionType
        userMarks: @userMarks
        followupSignal: @followupSignal
        otherMarks: @otherMarks
        itemTemplate: @view('profile/waterfallCollectionItem')
        badgeTemplate: @view('profile/badge')
        telescopeNotify: @user.telescope_notify
      #@drawBeam $(beam).find("canvas"), @current_subject, index for beam, index in @sub_beams
      @drawObs $(obs).find("canvas"), index, @data.collection[index] for obs, index in @profileObs
      
    if @user && !@user.seen_profile_notice
      @user.seenProfileNotice()
      @profileNotifySetup()

  
  addFavourite: (e) =>
    observation_id = $(e.currentTarget).data().id 
    User.first().addFavourite observation_id, @render
  
  removeFavourite: (e) =>
    observation_id = $(e.currentTarget).data().id 
    User.first().removeFavourite observation_id, @render
  
  gotUser: =>
    @user = User.first()
    #@collectionType = @inital_collection_type
    #@render()
    page = 1
    page = @collectionPage if @collectionPage
    @fetchType(@collectionType, page) if @user
  
  selectPage: (e) =>
    e.preventDefault()
    page = $(e.currentTarget).data().id
    @fetchType @collectionType, page
  
  selectCollectionType: (e) =>
    @collectionType = $(e.currentTarget).data().id 
    @fetchType @collectionType, 1
  
  fetchType: (type, page) =>
    @holdShow = false
    if @[type][page]
      @switchTo(type, page)
      return @render()
    
    return if @fetching
    @fetching = true
    $.getJSON "/user_#{ type }?page=#{ page }", (data) =>
      @data = data
      @[type][page] = data
      @switchTo type, page
      @render()
      @fetching = false
  
  switchTo: (type, page) =>
    @data = @[type][page]
    @collectionType = type
    @collectionPage = page
    @data.pages = 30 if @data.pages > 30

    @pagination.page = @data.page
    @pagination.pages = @data.pages
    @pagination.perPage = @data.per_page
    
  toggleTelescopeNotify: =>
    $.ajax
      type: 'POST'
      url: '/telescope_toggle_notify'
    User.fetch_current_user()
    @gotUser()

  toggleMarkingType: (e) =>
    temp = $(e.currentTarget).data().id
    if temp == 'userMarks'
      @userMarks = !@userMarks
      @markingType = '' if !@userMarks && @markingType == 'userMarks'
    if temp == 'followupSignal'
      @followupSignal = !@followupSignal
      @markingType = '' if !@followupSignal && @markingType == 'followupSignal'
    if temp == 'otherMarks'
      @otherMarks = !@otherMarks        
      @markingType = '' if !@otherMarks && @markingType == 'otherMarks'
    @holdShow = true # Avoid flashing with mouse movement after toggling off
    @render()
    @drawObs $(obs).find("canvas"), index, @data.collection[index] for obs, index in @profileObs
    
  showMarkingType: (e) =>
    unless @holdShow
      @markingType = $(e.currentTarget).data().id 
      @drawObs $(obs).find("canvas"), index, @data.collection[index] for obs, index in @profileObs
              
  hideMarkingType: (e) =>
    @holdShow = false
    @markingType = ""
    @drawObs $(obs).find("canvas"), index, @data.collection[index] for obs, index in @profileObs



  drawObs: (target, index, data) =>
    target.hide()
    ctx = target[0].getContext('2d')
    width = $(target[0]).width()
    height = $(target[0]).height()
    target[0].width = width
    target[0].height = height
    
    if ( ( @markingType=='followupSignal' ) || @followupSignal ) && data.followup_id
      mid = data.followup_signal[0]
      ang = data.followup_signal[1] # Counterclockwise from "down"
      start = [mid + 0.5 * Math.tan(ang), 1]
      end = [mid - 0.5 * Math.tan(ang), 0]
      @drawLine ctx, start, end, "magenta"
      #@drawLine ctx, line[0], line[1], "white" for line in data.followup_other_signals if data.followup_other_signals
      #@drawLine ctx, line[0], line[1], "magenta" for line in data.followup_user_signals if data.followup_user_signals
      
    if ( @markingType == 'userMarks' ) || @userMarks
      @drawLine ctx, line[0], line[1], "darkorange" for line in data.user_signals if data.user_signals
      
    if ( @markingType == 'otherMarks' ) || @otherMarks
      ctx.globalAlpha = 0.7
      @drawLine ctx, line[0], line[1], "green" for line in data.other_signals if data.other_signals
  
    target.show()
    
  drawLine: (ctx, start, end, color, isDashed = false ) =>
    width = ctx.canvas.width
    height = ctx.canvas.height
    ctx.strokeStyle = color
    x0 = width * start[0]
    ctx.beginPath()
    ctx.moveTo( width * start[0], height * start[1] )
    ctx.lineTo( width * end[0], height * end[1] )
    ctx.stroke()
    
  profileNotifySetup: =>
    dialog = new Dialog({el: $('#dialog-underlay'), content: @view('profile/dialog_content_profilenotify')()})

window.Profile = Profile
