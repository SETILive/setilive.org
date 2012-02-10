class Scene extends Spine.Controller
	@instances = []

	active: false

	enterDuration: 0
	exitDuration: 0

	timeouts: null

	# TEMPORARY: Use this instead of "animate", because IE can't animate transforms.
	# Even though the whole reason I'm not just using CSS is so that they'll animate in IE.
	# Keep an eye out for a fix: https://github.com/louisremi/jquery.transform.js
	# It should be easy to replace these all with "animate". I am so very sorry.
	dotAnimate: if $.browser.msie then 'css' else 'animate'

	constructor: ->
		console.log @dotAnimate
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
