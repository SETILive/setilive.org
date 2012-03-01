class Profile extends Spine.Controller
  pagination_no: 8
  inital_collection_type : 'favourites'

  events:
    'click .page' : 'selectPage'
    'click .collectionType' : 'selectCollectionType'
    'click .favourite'  :  'addFavourite'
    'click .favourited' :  'removeFavourite'

  
  
  favourites: []
  recents: []
  

  constructor: ->
    super
    User.bind('refresh', @gotUser)
    Badge.bind('refresh', @gotUser)
    @collectionType='favourites'

    @pagination =
    page : 0
    pages: 0
    noPerPage: @pagination_no
    menu:->
      JST["app/views/pagination"](@)


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
    console.log @pagination
    if @user
      @fetchType @collectionType, 0, (collection)=>
        @collection = collection
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
    pageNo = $(e.currentTarget).data().id
    fetchType @collectionType, pageNo, =>
      @render()

  selectCollectionType:(e)=>
    @collectionType =  $(e.currentTarget).data().id 
    @fetchType @collectionType, 0, (collection)=>
      @collection = collection
      @render()
  
  fetchType:(type, page, callback=null)=>
    console.log type
    if type =='favourites'
      return callback(@favourites[page]) if @favourites[page]
      $.getJSON "/user_favourites?page=#{page+1}", (data)=>
        console.log data
        @pagination.page = data.page 
        @pagination.pages= data.pages
        @pagination.noPerPage= data.per_page
        @favourites[page] = data.collection
        return callback(@favourites[page])
      
    else if type =='recents'
      return callback(@recents[page]) if @recents[page]
      $.getJSON "/user_recents?page=#{page+1}", (data)=>
        console.log data  
        @pagination.page = data.page 
        @pagination.pages= data.pages
        @pagination.noPerPage= data.per_page
        @recents[page] = data.collection
        return callback(@recents[page])

    callback([])

    
      
  
window.Profile = Profile