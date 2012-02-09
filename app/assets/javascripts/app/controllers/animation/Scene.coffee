class Scene extends Spine.Controller
	@instances = []

	enterDuration: 0
	exitDuration: 0

	loopTimeout: NaN

	constructor: ->
		Scene.instances.push @
		super
		@el.data 'scene', @
		@reset()

	reset: =>
		@$(':animated').stop(true, true)

	activate: =>
		activeSibling = @el.siblings('.active').data 'scene'
		if activeSibling then activeSibling.exit()
		setTimeout @enter, activeSibling?.exitDuration || 0

	enter: =>
		@el.addClass 'active'

	exit: =>
		@el.removeClass 'active'
		setTimeout @reset, @exitDuration + $.speed('slow').duration

window.Scene = Scene

window.scenes = Scene.instances
