class Scene extends Spine.Controller
	@instances = []

	enterDuration: 0
	loopDuration: NaN
	exitDuration: 0

	loopTimeout: NaN

	constructor: ->
		Scene.instances.push @
		super
		@reset()

	reset: =>
		clearTimeout @loopTimeout
		@$(':animated').stop(true, true)

	enter: =>
		unless isNaN @loopDuration
			@loopTimeout = setTimeout @loop, @enterDuration + $.speed('slow').duration

	loop: =>
		@loopTimeout = setTimeout @loop, @loopDuration

	exit: =>
		setTimeout @reset, @exitDuration + $.speed('slow').duration

window.Scene = Scene

window.scenes = Scene.instances

$ ->
	$('[data-animation-scene]').each ->
		SceneCtor = window[$(@).data 'animation-scene']
		new SceneCtor? el: @
