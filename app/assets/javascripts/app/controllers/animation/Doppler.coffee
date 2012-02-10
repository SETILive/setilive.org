#= require ./Scene

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
		@mountain.add(@tower).add(@towerWaves).add(@telescope)[@dotAnimate]
			opacity: 1
			transform: ''

		@towerPulse()

		@satelliteGoesRight()
		@satellitePulse()

	satelliteGoesRight: =>
		@satelliteGroup.css left: '', opacity: 0

		# Fade in, fade out
		@satelliteGroup[@dotAnimate] opacity: 1, {duration: 2500, queue: false}
		@defer 'satelliteFadeOut', @satelliteDuration - 2500, =>
			@satelliteGroup[@dotAnimate] opacity: 0, {duration: 2500, queue: false}

		# Rise, fall
		@satelliteGroup[@dotAnimate] transform: 'translateY(-50%)', {duration: @satelliteDuration / 2, queue: false}
		@defer 'satelliteFall', @satelliteDuration / 2, =>
			@satelliteGroup[@dotAnimate] transform: '', {duration: @satelliteDuration / 2, queue: false}

		# Move to the right
		@satelliteGroup[@dotAnimate] left: '+=90%', {
			duration: @satelliteDuration
			queue: false
		}

		@defer 'satelliteMove', @satelliteDuration + 1000, @satelliteGoesRight

	satellitePulse: =>
		period = 1500

		# TODO: This is really rough; I'm bad at math.

		groupLeft = @satelliteGroup.css 'left'
		percentLeft = parseFloat groupLeft
		if ~groupLeft.indexOf 'px' then percentLeft /= @el.width() else percentLeft /= 100

		if 0.1 < percentLeft < 0.3 then period /= 2

		@satelliteWaves[@dotAnimate] opacity: 1, 200
		@satelliteWaves[@dotAnimate] opacity: 0, 300

		@defer 'satellitePulse', period, @satellitePulse

	towerPulse: =>
		@towerWaves[@dotAnimate] opacity: 1, 200
		@towerWaves[@dotAnimate] opacity: 0, 300

		@defer 'towerPulse', 1500, @towerPulse

	exit: =>
		@mountain.add(@tower).add(@towerWaves)[@dotAnimate] opacity: 0, transform: 'translateX(-200px)', 1000
		@telescope[@dotAnimate] opacity: 0, transform: 'translateX(-800px)', 1000
		@satelliteGroup.css opacity: 0

window.Doppler = Doppler
