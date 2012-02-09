#= require ./Scene

class Doppler extends Scene
	enterDuration: 0
	exitDuration: 0

	elements:
		'.mountain': 'mountain'
		'.satellite, .waves.for-satellite': 'satelliteGroup'
		'.satellite': 'satellite'
		'.waves.for-satellite': 'satelliteWaves'
		'.tower': 'tower'
		'.waves.for-tower': 'towerWaves'
		'.telescope': 'telescope'

	reset: =>
		super

		@mountain.add(@tower).css
			opacity: 0
			transform: 'translateX(500px)'

		@telescope.css
			opacity: 0
			transform: 'translateX(1000px)'

		@satellite.css
			opacity: 0
			transform: 'translateX(-100px)'

		@satelliteWaves.add(@towerWaves).css opacity: 0

	enter: =>
		super

		@mountain.add(@tower).add(@telescope).add(@satellite).animate
			opacity: 1
			transform: ''

		@satelliteGoesRight()
		@satellitePulse()
		@towerPulse()

	satelliteGoesRight: =>
		@satellite.data 'direction', 'right'
		@satelliteGroup.animate left: '+=90%', {duration: 30000, queue: false, complete: @satelliteGoesLeft}

	satelliteGoesLeft: =>
		# TODO: This makes Firefox sad.
		@satellite.data 'direction', 'left'
		@satelliteGroup.animate left: '-=90%', {duration: 30000, queue: false, complete: @satelliteGoesRight}

	satellitePulse: =>
		wait = 1000

		# TODO: This is really rough; I'm bad at math.
		percentLeft = (parseFloat @satellite.css 'left') / @el.width()
		if 0.15 < percentLeft < 0.4 then wait = 333

		@satelliteWaves.delay(wait).animate opacity: 1, 200
		@satelliteWaves.animate opacity: 0, 300, @satellitePulse

	towerPulse: =>
		@towerWaves.delay(1000).animate opacity: 1, 200
		@towerWaves.animate opacity: 0, 300, @towerPulse

window.Doppler = Doppler
