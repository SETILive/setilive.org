
class About extends Spine.Controller
  constructor: ->
    super

  render: (current_view) =>
    @html @view "about/#{current_view}"
     
  active: (params) ->
    super
    
    switch params.content
      when 'ted' then @render params.content
      when 'gallery'
        @render params.content
        $('#gallery').html @view('about/gallery/waterfalls')(window.galleryWaterfalls)
        $(".exampleHolder").hover ->
          $(this).parent().find(".gallery_explination").hide()
          $(this).parent().find(".gallery_explination2").show()
        , ->
          $(this).parent().find(".gallery_explination").show()
          $(this).parent().find(".gallery_explination2").hide()
      when 'video_tutorial' then @render params.content
      when 'team'
        @render params.content
        $('#about_menu a').click (e) ->
          e.preventDefault()
          link = $(e.currentTarget).data 'link'
          link_offset = $("#aboutpage a[name=#{link}]").offset().top
          $(window).scrollTop link_offset
      else
        @render 'about'
        $('[data-animation-scene]').parent().each ->
          stage = new Stage el: @

          $(@).children('[data-animation-scene]').each ->
            $el = $(@)
            Ctor = window[$el.data 'animation-scene']
            scene = new Ctor el: @
            stage.scenes.push scene

            if $el.hasClass 'active' then setTimeout scene.activate, 10

  deactivate: ->
    super
    @el.html ''







window.About = About