class Results extends Spine.Controller

	constructor: ->
		super
		$.getJSON window.location.href+".json", (data)=>
			@render(data)
			

	render:(data)=>
		@html @view('results')(data)


window.Results = Results 