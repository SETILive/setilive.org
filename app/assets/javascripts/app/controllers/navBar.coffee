class NavBar extends Spine.Controller

  constructor: ->
    super
    @el.attr("id", "top")
    User.bind('refresh',@render)
    @render()
  
  render:=>
    console.log "user is ", User.first()
    @html @view('navBar')
      user : User.first()

window.NavBar=NavBar