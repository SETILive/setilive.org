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
		# Override

	activate: =>
		@el.addClass 'active'
		@active = true

		activeSibling = @el.siblings('.active').data 'scene'
		activeSibling?.deactivate()

		setTimeout @enter, activeSibling?.exitDuration or 0

	enter: =>
		# Override

	deactivate: =>
		@stopAnimating()

		@active = false
		@el.removeClass 'active'

		setTimeout @reset, @exitDuration + 1000

		setTimeout @exit, 0

	stopAnimating: =>
		@$(':animated').stop(true, true)
		el.queue([]) for name, el in @elements

	exit: =>
		# Override

window.Scene = Scene

window.scenes = Scene.instances
