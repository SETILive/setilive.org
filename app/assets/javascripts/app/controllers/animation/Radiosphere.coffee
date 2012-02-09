#= require ./Scene

class Radiosphere extends Scene
	exitDuration: 2500

	elements:
		'.ring': 'rings'
		'.outer.ring': 'outerRing'
		'.middle.ring': 'middleRing'
		'.inner.ring': 'innerRing'
		'.radio-waves': 'radioWaves'
		'.main.planet': 'mainPlanet'
		'.radio': 'radio'
		'.planet': 'planets'
		'.tiny.planet': 'tinyPlanet'
		'.small.planet': 'smallPlanet'
		'.other.planet': 'otherPlanet'

	reset: =>
		super

		@el.css opacity: 0

		@mainPlanet.css opacity: 1, transform: 'scale(0.01)'
		@innerRing.css opacity: 1, transform: 'translateY(-21%) scale(0.01)'
		@middleRing.css opacity: 1, transform: 'translateY(-23%) scale(0.01)'
		@outerRing.css opacity: 1, transform: 'translateY(-25%) scale(0.01)'

		@tinyPlanet.css opacity: 1, transform: 'translate(-10%, -10%) scale(0.01)'
		@smallPlanet.css opacity: 1, transform: 'translate(300%, -150%) scale(0.01)'
		@otherPlanet.css opacity: 1, transform: 'translate(-200%, -150%) scale(0.01)'

		@radio.css opacity: 0, transform: 'scale(1, 0.01)'
		@radioWaves.css opacity: 0

	enter: =>
		super

		@el.css opacity: 1

		@outerRing.animate transform: '', 500
		@middleRing.animate transform: '', 750
		@innerRing.animate transform: '', 1000

		@mainPlanet.animate transform: '', 1500
		@radio.delay(2000).animate opacity: 1, transform: '', 250

		@tinyPlanet.animate transform: '', 2500, @loop
		@smallPlanet.animate transform: '', 1500
		@otherPlanet.animate transform: '', 1000

	loop: =>
		return unless @active

		@radioWaves.animate(opacity: 1, 250).animate opacity: 0, 250
		@innerRing.delay(250).animate(transform: 'scale(1.1)', 250).animate transform: '', 250
		@middleRing.delay(500).animate(transform: 'scale(1.1)').animate transform: ''
		@outerRing.delay(750).animate(transform: 'scale(1.1)').animate transform: ''
		@smallPlanet.delay(750).animate(transform: 'scale(1.2)').animate transform: ''
		@otherPlanet.delay(1000).animate(transform: 'scale(1.1)').animate transform: '', @loop

	exit: =>
		super

		@outerRing.animate opacity: 0, transform: 'translateY(70%) scale(3)', 500
		@middleRing.animate opacity: 0, transform: 'translateY(75%) scale(3)', 1000
		@innerRing.animate opacity: 0, transform: 'translateY(80%) scale(3)', 1500

		@mainPlanet.animate opacity: 0, transform: 'translateY(85%) scale(3)', 2000
		@radio.animate opacity: 0, 250

		@tinyPlanet.animate opacity: 0, transform: 'translate(500%, 500%) scale(3)', 2500
		@smallPlanet.animate opacity: 0, transform: 'translate(50%, 500%) scale(3)', 1500
		@otherPlanet.animate opacity: 0, transform: 'translate(500%, 500%) scale(3)', 1000

window.Radiosphere = Radiosphere
