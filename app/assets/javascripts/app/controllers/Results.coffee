class Results extends Spine.Controller

	constructor: ->
		super
		console.log "fetching from #{window.location.href+".json"}"
		$.getJSON window.location.href+".json", (data)=>
			@render(data)
			

	render:(data)=>
		@html @view('results')(data)


window.Results = Results 