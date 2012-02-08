#= require ./Scene

class Ata extends Scene
	enterDuration: 667
	exitDuration: 3000

	elements:
		'.mountain': 'mountain'

		'.far.scope': 'farScopes'
		'.first.far.scope': 'firstFarScope'
		'.second.far.scope': 'secondFarScope'
		'.third.far.scope': 'thirdFarScope'

		'.near.scope': 'nearScopes'
		'.first.near.scope': 'firstNearScope'
		'.second.near.scope': 'secondNearScope'

	reset: =>
		super
		images = @mountain.add(@farScopes).add(@nearScopes)

		images.css
			height: ''
			left: ''
			opacity: ''

		images.each ->
			$el = $(@)
			$el.data 'naturalHeight', $el.height()
			$el.height 0

	enter: =>
		super
		@mountain.animate
			height: @mountain.data 'naturalHeight'

		@farScopes.delay(667).animate
			height: @farScopes.data 'naturalHeight'

		@nearScopes.delay(333).animate
			height: @nearScopes.data 'naturalHeight'

	exit: =>
		super
		@mountain.animate left: '-=100%', opacity: 0, 3000
		@farScopes.animate left: '-=100%', opacity: 0, 2500
		@nearScopes.animate left: '-=100%', opacity: 0,  2000
			
window.Ata = Ata
