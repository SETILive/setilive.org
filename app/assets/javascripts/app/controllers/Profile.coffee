class Profile extends Spine.Controller
  pagination_no: 8
  inital_collection_type : 'favourites'

  events:
    'click .page' : 'selectPage'
    'click .collectionType' : 'selectCollectionType'

  constructor: ->
    super
    User.bind('refresh',@gotUser)
    @collectionType='favourites'

  gotUser:=>
    @user= User.first()
    @collectionType= @inital_collection_type
    @paginate()
    @render()

  render:=> 
    @append @view('user_stats')(@user)
    @append @view('user_profile')
      user: @user
      pagination : @pagination
      subjects : [1..20] #@user[@collectionType]
      collectionType: @collectionType
  
  selectPage:(e)=>
    e.preventDefault()
    @pagnination.page = $(e.currentTarget).data().id
    @render()

  selectCollectionType:(e)=>
    e.preventDefault()
    @collectionType =  $(e.currentTarget).data().collection_type
    @paginate()
    @render()

  paginate:=>
    console.log("collection type is ", @collectionType)
    collection = @user[@collectionType]
    @pagination =
      page : 0
      pages: collection.length/@pagination_no
      noPerPage: @pagination_no
      start: ->
        @page*@noPerPage
      end: ->
        (@page+1)*@noPerPage
      
  
window.Profile = Profile