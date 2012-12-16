
class Profile extends Spine.Controller
  inital_collection_type: 'favourites'
  
  events:
    'click .page': 'selectPage'
    'click .collectionType': 'selectCollectionType'
    'click .favourite':  'addFavourite'
    'click .favourited':  'removeFavourite'
    'click  #email_opt_img': 'toggleTelescopeNotify'
  
  constructor: ->
    super
    $("#notification_bar").show()
    @collectionType = 'favourites'
    @favourites = {}
    @recents = {}
    
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
      @gotUser()

  deactivate: ->
    super
    @el.html ''
    User.unbind 'refresh', @gotUser

  render: => 
    @html ""
    @append @view('profile/user_stats')(@user)
    
    @append @view('profile/user_profile')
      user: @user
      pagination: @pagination
      subjects: @data?.collection or []
      collectionType: @collectionType
      itemTemplate: @view('profile/waterfallCollectionItem')
      badgeTemplate: @view('profile/badge')
      telescopeNotify: @user.telescope_notify
  
  addFavourite: (e) =>
    observation_id = $(e.currentTarget).data().id 
    User.first().addFavourite observation_id, @render
  
  removeFavourite: (e) =>
    observation_id = $(e.currentTarget).data().id 
    User.first().removeFavourite observation_id, @render
  
  gotUser: =>
    @user = User.first()
    @collectionType = @inital_collection_type
    @render()
    @fetchType(@collectionType, 1) if @user
  
  selectPage: (e) =>
    e.preventDefault()
    page = $(e.currentTarget).data().id
    @fetchType @collectionType, page
  
  selectCollectionType: (e) =>
    @collectionType = $(e.currentTarget).data().id 
    @fetchType @collectionType, 1
  
  fetchType: (type, page) =>
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

window.Profile = Profile
