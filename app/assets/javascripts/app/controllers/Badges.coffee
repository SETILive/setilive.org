class Badges extends Spine.Controller
  inital_collection_type : 'favourites'

  events:
    'click .page' : 'selectPage'
    'click .collectionType' : 'selectCollectionType'

  constructor: ->
    super
    User.bind('refresh',@gotUser)
    Badge.bind('refresh', @gotUser)
    @collectionType='favourites'

  gotUser:=>
    @user= User.first()
    @mainBadge = Badge.find(window.location.pathname.split("/")[2])
 
    @render()

  render:=> 
    @html ""
    @append @view('user_stats')(@user)
    @append @view('badge_details')
      user: @user
      mainBadge: @mainBadge
      pagination : @pagination
      subjects : [1..20] #@user[@collectionType]
      collectionType: @collectionType
      badgeTemplate: @view('badge')
      twitterTemplate: @view('twitterBadge')
      facebookTemplate: @view('facebookBadge')
  

  
window.Badges = Badges