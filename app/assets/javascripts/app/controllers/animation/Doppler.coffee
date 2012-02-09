#= require ./Scene

delay = (wait, fn) ->
	setTimeout fn, wait

class Doppler extends Scene
	exitDuration: 1000

	satelliteDuration: 30000

	elements:
		'.mountain': 'mountain'
		'.satelliteGroup': 'satelliteGroup'
		'.satellite': 'satellite'
		'.waves.for-satellite': 'satelliteWaves'
		'.tower': 'tower'
		'.waves.for-tower': 'towerWaves'
		'.telescope': 'telescope'

	reset: =>
		@mountain.add(@tower).add(@towerWaves).css
			opacity: 0
			transform: 'translateX(200px)'

		@telescope.css
			opacity: 0
			transform: 'translateX(800px)'

		@satelliteGroup.css
			left: ''
			opacity: 0

	enter: =>
		@satelliteGoesRight()
		@satellitePulse()

		@mountain.add(@tower).add(@towerWaves).add(@telescope).animate
			opacity: 1
			transform: ''

		@towerPulse()

	satelliteGoesRight: =>
		@satelliteGroup.css left: ''

		# Fade in, fade out
		@satelliteGroup.animate opacity: 1, {duration: 2500, queue: false}
		delay @satelliteDuration - 2500, =>
			@satelliteGroup.animate opacity: 0, {duration: 2500, queue: false}

		# Rise, fall
		@satelliteGroup.animate transform: 'translateY(-50%)', {duration: @satelliteDuration / 2, queue: false}
		delay @satelliteDuration / 2, =>
			@satelliteGroup.animate transform: '', {duration: @satelliteDuration / 2, queue: false}

		# Move to the right
		@satelliteGroup.animate left: '+=90%', {
			duration: @satelliteDuration
			easing: 'linear'
			queue: false
		}

		@timeouts.satelliteMove = delay @satelliteDuration + 1000, @satelliteGoesRight

	satellitePulse: =>
		period = 1000

		# TODO: This is really rough; I'm bad at math.

		groupLeft = @satelliteGroup.css 'left'
		percentLeft = parseFloat groupLeft
		if ~groupLeft.indexOf 'px' then percentLeft /= @el.width() else percentLeft /= 100

		if 0.1 < percentLeft < 0.3 then period = 333

		@satelliteWaves.animate opacity: 1, 200
		@satelliteWaves.animate opacity: 0, 300

		@timeouts.satellitePulse = delay period, @satellitePulse

	towerPulse: =>
		@timeouts.towerPulse =  delay 1000, @towerPulse
		@towerWaves.animate opacity: 1, 200
		@towerWaves.animate opacity: 0, 300

	exit: =>
		@mountain.add(@tower).animate opacity: 0, transform: 'translateX(-200px)', 1000
		@telescope.animate opacity: 0, transform: 'translateX(-800px)', 1000
		@satellite.animate opacity: 0, transform: 'translateX(100px)', 1000

window.Doppler = Doppler
