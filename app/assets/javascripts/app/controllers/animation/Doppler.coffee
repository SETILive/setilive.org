#= require ./Scene

class Doppler extends Scene
	exitDuration: 1000

	elements:
		'.mountain': 'mountain'
		'.satellite, .waves.for-satellite': 'satelliteGroup'
		'.satellite': 'satellite'
		'.waves.for-satellite': 'satelliteWaves'
		'.tower': 'tower'
		'.waves.for-tower': 'towerWaves'
		'.telescope': 'telescope'

	reset: =>
		@mountain.add(@tower).css
			opacity: 0
			transform: 'translateX(200px)'

		@telescope.css
			opacity: 0
			transform: 'translateX(800px)'

		@satellite.add(@satelliteWaves).css
			left: ''
			opacity: 0
			transform: 'translateX(-100px)'

		@satelliteWaves.add(@towerWaves).css opacity: 0

	enter: =>
		@mountain.add(@tower).add(@telescope).add(@satellite).add(@satelliteWaves).animate
			opacity: 1
			transform: ''

		@satelliteGoesRight()
		@satellitePulse()
		@towerPulse()

	satelliteGoesRight: =>
		return unless @active

		@satellite.data 'direction', 'right'
		@satelliteGroup.animate left: '+=90%', {duration: 30000, queue: false, complete: @satelliteGoesLeft}

	satelliteGoesLeft: =>
		return unless @active

		# TODO: This makes Firefox sad.
		@satellite.data 'direction', 'left'
		@satelliteGroup.animate left: '-=90%', {duration: 30000, queue: false, complete: @satelliteGoesRight}

	satellitePulse: =>
		return unless @active

		wait = 1000

		# TODO: This is really rough; I'm bad at math.
		percentLeft = (parseFloat @satellite.css 'left') / @el.width()
		if 0.15 < percentLeft < 0.4 then wait = 333

		@satelliteWaves.delay(wait).animate opacity: 1, 200
		@satelliteWaves.animate opacity: 0, 300, @satellitePulse

	towerPulse: =>
		return unless @active

		@towerWaves.delay(1000).animate opacity: 1, 200
		@towerWaves.animate opacity: 0, 300, @towerPulse

	exit: =>
		@mountain.add(@tower).animate opacity: 0, transform: 'translateX(-200px)', 1000
		@telescope.animate opacity: 0, transform: 'translateX(-800px)', 1000
		@satellite.animate opacity: 0, transform: 'translateX(100px)', 1000

window.Doppler = Doppler
