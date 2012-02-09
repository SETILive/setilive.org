#+ require ./Scene

class Stage extends Spine.Controller
	@instances: []

	scenes: null

	controlsTemplate: '''
		<div class="controls">
			<button class="previous">Previous</button>
			<button class="next">Next</button>
		</div>
	'''

	events:
		'click .previous': 'goPrevious'
		'click .next': 'goNext'

	constructor: ->
		Stage.instances.push @
		super
		@scenes = []
		@addControls()

	addControls: =>
		@el.append @controlsTemplate

	goPrevious: =>
		@el.children('.active').prev().data('scene').activate()

	goNext: =>
		@el.children('.active').next().data('scene').activate()

window.Stage = Stage
window.stages = Stage.instances

$ ->
	$('[data-animation-scene]').parent().each ->
		stage = new Stage el: @

		$(@).children('[data-animation-scene]').each ->
			$el = $(@)
			Ctor = window[$el.data 'animation-scene']
			scene = new Ctor el: @
			stage.scenes.push scene

			if $el.hasClass 'active' then setTimeout scene.activate, 10
