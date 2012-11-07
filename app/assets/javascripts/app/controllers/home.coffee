
class Home extends Spine.Controller
  elements:
    '#home_content': 'home_content'
    '#most_recent_badge': 'home_badge'
    '#subjects': 'subjects'
    '#global_stats': 'global_stats'

  constructor: ->
    super

  active: ->
    super
    $("#notification_bar").hide()
    @render()

  deactivate: =>
    @el.removeClass 'active'
    @el.empty()
    
  render: ->
    @html @view('home')()

    Metric.fetch(@renderStats)
    @home_content.html @view('home_main_content')()

    User.bind 'refresh', =>
      @renderObservations() if @observations
    
    Classification.fetchRecent (observations) =>
      @observations = observations
      @renderObservations()

    User.bind 'create', (user) =>
      @home_badge.html @view('home_badge')
        user: user

    @home_badge.html @view('home_badge')

  renderObservations: =>
    self = @
    $('#subjects').html @view('observation')
        observations: @observations
        user: User.first()

    $('#subjects .favourite').click ->
        observation_id = $(@).data().id 
        User.first().addFavourite observation_id, =>
          self.renderObservations()

    $('#subjects .favourited').click ->
        observation_id = $(@).data().id 
        User.first().removeFavourite observation_id, =>
          self.renderObservations()

  renderStats: =>
    new Metrics({el: @global_stats})

window.Home = Home