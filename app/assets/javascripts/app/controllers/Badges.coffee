
class Badges extends Spine.Controller

  inital_collection_type: 'favourites'

  events:
    'click .page': 'selectPage'
    'click .collectionType': 'selectCollectionType'

  constructor: (params) ->
    super
    @collectionType = 'favourites'

  active: (params) =>
    super
    @badge_id = params.id

    if User.first() and Badge.count() > 0
      @dataReceived()

    User.bind 'refresh', @dataReceived
    Badge.bind 'refresh', @dataReceived

  deactivate: =>
    @el.removeClass 'active'
    @el.empty()

    User.unbind 'refresh', @dataReceived
    Badge.unbind 'refresh', @dataReceived

  dataReceived: =>
    if User.first() and Badge.count() > 0
      @user = User.first()
      @mainBadge = Badge.find @badge_id
      @render()

  render: => 
    @html ""
    @append @view('profile/user_stats')(@user)
    @append @view('profile/badge_details')
      user: @user
      mainBadge: @mainBadge
      pagination: @pagination
      subjects: [1..20] #@user[@collectionType]
      collectionType: @collectionType
      badgeTemplate: @view('profile/badge')
      twitterTemplate: @view('profile/twitterBadge')
      facebookTemplate: @view('profile/facebookBadge')
  
window.Badges = Badges