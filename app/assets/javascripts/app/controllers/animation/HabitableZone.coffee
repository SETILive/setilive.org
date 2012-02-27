#= require ./Scene

class HabitableZone extends Scene
	exitDuration: 1000

	elements:
		'.outer.ring': 'outerRing'
		'.inner.ring': 'innerRing'
		'.star': 'star'
		'.planet': 'planet'
		'.flag': 'flags'
		'.flag.for-star': 'starFlag'
		'.flag.for-planet': 'planetFlag'
		'.flag.for-zone': 'zoneFlag'
		'h1': 'title'

	reset: =>
		@outerRing.add(@innerRing).add(@star).css
			opacity: 0
			transform: 'translateY(-200%)'

		@planet.add(@flags).css
			opacity: 0
			transform: 'translateY(-400%)'

	enter: =>
		@outerRing.animate opacity: 1, transform: 'translateY(20%)'
		@outerRing.animate transform: 'translateY(-10%)'
		@outerRing.animate transform: ''

		@innerRing.delay(100).animate opacity: 1, transform: 'translateY(20%)'
		@innerRing.animate transform: 'translateY(-10%)'
		@innerRing.animate transform: ''

		@star.delay(200).animate opacity: 1, transform: 'translateY(0)'
		@star.animate transform: 'scaleY(0.95)'
		@star.animate transform: ''

		@planet.delay(300).animate opacity: 1, transform: 'translateY(10%)'
		@planet.delay(300).animate transform: ''

		@starFlag.delay(1000).animate opacity: 1, transform: ''
		@planetFlag.delay(1500).animate opacity: 1, transform: ''
		@zoneFlag.delay(2000).animate opacity: 1, transform: ''

		@title.delay(2500).animate opacity: 1, transform: ''

	exit: =>
		@outerRing.add(@zoneFlag).animate
			opacity: 0
			transform: 'translateY(200%)'

		@innerRing.add(@star).add(@starFlag).delay(200).animate
			opacity: 0
			transform: 'translateY(200%)'

		@planet.add(@planetFlag).delay(600).animate
			opacity: 0
			transform: 'translateY(200%)'

		@title.animate opacity: 0, transform: 'translateX(-800px)', 1000

window.HabitableZone = HabitableZone
