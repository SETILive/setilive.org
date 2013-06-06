
class Review extends Spine.Controller

  elements:
    '#classify-area': 'classify_area'

  constructor: ->
    super
    @user_set = -1

    User.bind 'refresh', (user) =>
      @user_set = if user then 1 else 0

  active: (params) =>
    super
    $("#notification_bar").show()
    if @user_set < 0
      @timeout_id = window.setTimeout @active, 1000, params
    else
      if @user_set > 0
        @setupPage params
      else
        window.location = '/login'

  setupPage: (params) =>
    @html @view 'review/review'

    @delay =>
      @cleanup()
      @subjects = new SubjectsRev({el: $("#waterfalls")})
      @info = new InfoRev({el: $("#info")})

      Subject.fetch(params.id)
    
    unless User.first().seen_reviewpage_notice
      User.first().seenReviewpageNotice()
      @reviewNotifySetup()

  deactivate: =>
    super
    @cleanup()
    @el.empty()

  cleanup: =>
    Subject.unbind()
    Spine.unbind 'toggleMarkingType'
    Spine.unbind 'showMarkingType'
    Spine.unbind 'hideMarkingType'
    Spine.unbind 'nextInChain'
    Spine.unbind 'prevInChain'
    Spine.unbind 'beamChange'

    if @subjects?
      @subjects.release()

    if @info?
      @info.release()

  reviewNotifySetup: =>
    dialog = new Dialog({el: $('#dialog-underlay'), content: @view('review/dialog_content_reviewpagenotify')()})


window.Review = Review