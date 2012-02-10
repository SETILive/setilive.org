#= require ./Scene

class Ata extends Scene
	exitDuration: 1000

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
		@mountain.css   opacity: 0, transform: 'translateX(200px)', 2000
		@farScopes.css  opacity: 0, transform: 'translateX(400px)', 2000
		@nearScopes.css opacity: 0, transform: 'translateX(800px)', 2000

	enter: =>
		@mountain.animate   opacity: 1, transform: 'translateX(0)', 1000
		@farScopes.animate  opacity: 1, transform: 'translateX(0)', 1000
		@nearScopes.animate opacity: 1, transform: 'translateX(0)', 1000

	exit: =>
		@mountain.animate   opacity: 0, transform: 'translateX(-200px)', 1000
		@farScopes.animate  opacity: 0, transform: 'translateX(-400px)', 1000
		@nearScopes.animate opacity: 0, transform: 'translateX(-800px)', 1000

window.Ata = Ata
