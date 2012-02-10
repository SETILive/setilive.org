class Scene extends Spine.Controller
	@instances = []

	active: false

	enterDuration: 0
	exitDuration: 0

	timeouts: null

	constructor: ->
		Scene.instances.push @
		super
		@timeouts = {}
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
		@$(':animated').stop true, true
		for name, el of @elements then @[el].clearQueue()
		for name, timeout of @timeouts then clearTimeout timeout

	exit: =>
		# Override

	# Call a function later.
	# Automatically stopped on deactivation.
	defer: (name, wait, fn) =>
		@timeouts[name] = setTimeout @proxy(fn), wait

window.Scene = Scene

window.scenes = Scene.instances
