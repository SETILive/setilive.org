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
		@el.css opacity: 1

		@outerRing[@dotAnimate] transform: '', 500
		@middleRing[@dotAnimate] transform: '', 750
		@innerRing[@dotAnimate] transform: '', 1000

		@mainPlanet[@dotAnimate] transform: '', 1500
		@radio.delay(2000)[@dotAnimate] opacity: 1, transform: '', 250

		@tinyPlanet[@dotAnimate] transform: '', 2000, @loop
		@smallPlanet[@dotAnimate] transform: '', 667
		@otherPlanet[@dotAnimate] transform: '', 333

	loop: =>
		@radioWaves[@dotAnimate](opacity: 1, 250)[@dotAnimate] opacity: 0, 250
		@innerRing.delay(250)[@dotAnimate](transform: 'scale(1.1)', 250)[@dotAnimate] transform: '', 250
		@middleRing.delay(500)[@dotAnimate](transform: 'scale(1.1)')[@dotAnimate] transform: ''
		@outerRing.delay(750)[@dotAnimate](transform: 'scale(1.1)')[@dotAnimate] transform: ''
		@smallPlanet.delay(750)[@dotAnimate](transform: 'scale(1.2)')[@dotAnimate] transform: ''
		@otherPlanet.delay(1000)[@dotAnimate](transform: 'scale(1.1)')[@dotAnimate] transform: ''

		@defer 'loop', 3000, @loop

	exit: =>
		@radio[@dotAnimate] opacity: 0, 250

		@outerRing[@dotAnimate] opacity: 0, transform: 'translateY(170%) scale(3)', 500
		@middleRing[@dotAnimate] opacity: 0, transform: 'translateY(175%) scale(3)', 1000
		@innerRing[@dotAnimate] opacity: 0, transform: 'translateY(180%) scale(3)', 1500

		@mainPlanet[@dotAnimate] opacity: 0, transform: 'translateY(185%) scale(3)', 1500

		@tinyPlanet[@dotAnimate] opacity: 0, transform: 'translate(100%, -100%%) scale(3)', 2500
		@smallPlanet[@dotAnimate] opacity: 0, transform: 'translate(-500%, 350%) scale(3)', 1500
		@otherPlanet[@dotAnimate] opacity: 0, transform: 'translate(1000%, 600%) scale(3)', 1000

window.Radiosphere = Radiosphere
