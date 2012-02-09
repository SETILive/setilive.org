class Scene extends Spine.Controller
	@instances = []

	enterDuration: 0
	loopDuration: NaN
	exitDuration: 0

	loopTimeout: NaN

	constructor: ->
		Scene.instances.push @
		super
		@el.data 'scene', @
		@reset()

	reset: =>
		clearTimeout @loopTimeout
		@$(':animated').stop(true, true)

	activate: =>
		activeSibling = @el.siblings('.active').data 'scene'
		if activeSibling then activeSibling.exit()
		setTimeout @enter, activeSibling?.exitDuration || 0

	enter: =>
		@el.addClass 'active'

		unless isNaN @loopDuration
			@loopTimeout = setTimeout @loop, @enterDuration + $.speed('slow').duration

	loop: =>
		@loopTimeout = setTimeout @loop, @loopDuration

	exit: =>
		@el.removeClass 'active'
		setTimeout @reset, @exitDuration + $.speed('slow').duration

window.Scene = Scene

window.scenes = Scene.instances
