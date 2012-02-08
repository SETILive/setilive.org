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

	enter: =>
		@loopTimeout = setTimeout @loop, @enterDuration + 10 unless isNaN @loopDuration

	loop: =>
		@loopTimeout = setTimeout @loop, @loopDuration

	exit: =>
		setTimeout @reset, @exitDuration + 100

window.Scene = Scene

window.scenes = Scene.instances

$ ->
	$('[data-animation-scene]').each ->
		SceneCtor = window[$(@).data 'animation-scene']
		new SceneCtor? el: @
