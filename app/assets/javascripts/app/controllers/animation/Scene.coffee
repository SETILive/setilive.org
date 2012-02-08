class Scene extends Spine.Controller
	@instances = []

	enterDuration: 0
	exitDuration: 0
	loopDuration: NaN

	loopTimeout: NaN

	constructor: ->
		Scene.instances.push @
		super
		@reset()

	reset: =>
		clearTimeout @loopTimeout

	enter: =>
		if @loopDuration then @loopTimeout = setTimeout @loop, @enterDuration + 10

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
