
class Login extends Spine.Controller
  
  constructor: ->
    super
    @activatePlaceholders()

  activatePlaceholders: ->
    $('span.placeholder').click ->
        $(@).hide()
        $(@).parent().find('input').focus()
    
    $('input').focus ->
        $(@).parent().find('span.placeholder').hide()
    
    $('input').blur ->
        $(@).parent().find('span.placeholder').show() if $(@).val() is ''


window.Login = Login