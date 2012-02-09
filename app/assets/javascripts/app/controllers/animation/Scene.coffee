class Scene extends Spine.Controller
	@instances = []

	active: false

	enterDuration: 0
	exitDuration: 0

	loopTimeout: NaN

	constructor: ->
		Scene.instances.push @
		super
		@el.data 'scene', @
		@reset()

	reset: =>

	activate: =>
		activeSibling = @el.siblings('.active').data 'scene'
		if activeSibling then activeSibling.exit()
		setTimeout @enter, activeSibling?.exitDuration || 0

	enter: =>
		@el.addClass 'active'
		@active = true

	exit: =>
		el.stop(true, true) for name, el in @elements
		@active = false
		@el.removeClass 'active'
		setTimeout @reset, @exitDuration + $.speed('slow').duration

window.Scene = Scene

window.scenes = Scene.instances
