class Profile extends Spine.Controller
  pagination_no: 8
  inital_collection_type : 'favourites'

  events:
    'click .page' : 'selectPage'
    'click .collectionType' : 'selectCollectionType'
    'click .favourite'  :  'addFavourite'
    'click .favourited' :  'removeFavourite'

  constructor: ->
    super
    User.bind('refresh', @gotUser)
    Badge.bind('refresh', @gotUser)
    @collectionType='favourites'


  addFavourite:(e)=>
    observation_id = $(e.currentTarget).data().id 
    User.first().addFavourite observation_id, =>
      @render()

  removeFavourite:(e)=>
    observation_id = $(e.currentTarget).data().id 
    User.first().removeFavourite observation_id, =>
      @render()

  gotUser:=>
    @user= User.first()
    @collectionType= @inital_collection_type
    @collection = []
    @paginate()

    @fetchType @collectionType, (collection)=>
      @collection = collection
      @paginate()
      @render()
      
    @render()

  render:=> 
    @html ""
    @append @view('user_stats')(@user)
    

    @append @view('user_profile')
      user: @user
      pagination : @pagination
      subjects : @collection
      collectionType: @collectionType
      itemTemplate: @view('waterfallCollectionItem')
      badgeTemplate: @view('badge')
  
  selectPage:(e)=>
    e.preventDefault()
    @pagination.page = $(e.currentTarget).data().id
    @render()

  selectCollectionType:(e)=>

    @collectionType =  $(e.currentTarget).data().id 
    @fetchType @collectionType, (collection)=>
      @collection = collection
      @paginate()
      @render()
  
  fetchType:(type, callback=null)=>
    console.log "selected #{type}, favourites"
    if type =='favourites'
      console.log "fetching favourites",@favourites
      return callback(@favourites) if @favourites
      $.getJSON '/user_favourites', (data)=>
        @favourites = data
        return callback(@favourites)
      
    else if type =='recents'
      return callback(@recents) if @recents
      $.getJSON '/user_recents', (data)=>
        @recents = data
        return callback(@recents)

    callback([])

  paginate:=>
    
    @pagination =
      page : 0
      pages: @collection.length/@pagination_no
      noPerPage: @pagination_no
      start: ->
        @page*@noPerPage
      end: ->
        (@page+1)*@noPerPage
      menu:->
        JST["app/views/pagination"](@)
      
  
window.Profile = Profile