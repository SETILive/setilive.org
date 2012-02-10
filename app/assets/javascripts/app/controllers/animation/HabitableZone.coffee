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

	reset: =>
		@outerRing.add(@innerRing).add(@star).css
			opacity: 0
			transform: 'translateY(-200%)'

		@planet.add(@flags).css
			opacity: 0
			transform: 'translateY(-400%)'

	enter: =>
		@outerRing[@dotAnimate] opacity: 1, transform: 'translateY(20%)'
		@outerRing[@dotAnimate] transform: 'translateY(-10%)'
		@outerRing[@dotAnimate] transform: ''

		@innerRing.delay(100)[@dotAnimate] opacity: 1, transform: 'translateY(20%)'
		@innerRing[@dotAnimate] transform: 'translateY(-10%)'
		@innerRing[@dotAnimate] transform: ''

		@star.delay(200)[@dotAnimate] opacity: 1, transform: 'translateY(0)'
		@star[@dotAnimate] transform: 'scaleY(0.95)'
		@star[@dotAnimate] transform: ''

		@planet.delay(300)[@dotAnimate] opacity: 1, transform: 'translateY(10%)'
		@planet.delay(300)[@dotAnimate] transform: ''

		@starFlag.delay(1000)[@dotAnimate] opacity: 1, transform: ''
		@planetFlag.delay(1500)[@dotAnimate] opacity: 1, transform: ''
		@zoneFlag.delay(2000)[@dotAnimate] opacity: 1, transform: ''

	exit: =>
		@outerRing.add(@zoneFlag)[@dotAnimate]
			opacity: 0
			transform: 'translateY(200%)'

		@innerRing.add(@star).add(@starFlag).delay(200)[@dotAnimate]
			opacity: 0
			transform: 'translateY(200%)'

		@planet.add(@planetFlag).delay(600)[@dotAnimate]
			opacity: 0
			transform: 'translateY(200%)'

window.HabitableZone = HabitableZone
