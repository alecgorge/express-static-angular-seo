PORT 			= process.env['NODE_PORT'] || 8888

express 		= require 'express'
phantomjs 		= require 'phantomjs'
phantom 		= require 'node-phantom'

app 			= express()

phantom_options = {
	parameters:
		'disk-cache':'no'
		'ignore-ssl-errors':'true'
		'load-images':'false'
		'local-to-remote-url-access':'yes'
	'phantomPath': phantomjs.path
	onStdOut: (data) -> return # discard
	onStdErr: (data) -> return
}

app.configure ->
	app.use express.logger("dev")

app.get '*', (req, res) ->
	host = req.get('x-host') or req.get('host')
	url = req.url

	full_url = "http://#{host}#{url}"

	create_page = (err, ph) ->
		res.send(500, err) if err

		ph.createPage (err, page) ->
			res.send(500, err) if err

			page.onCallback = (data) ->
				if data?.rendered
					res.send data.rendered
					ph.exit()

			page.open full_url, (err, status) ->
				res.send(500, err) if err

	phantom.create create_page, phantom_options

app.listen PORT

console.log "Listening on port #{PORT}"
console.log "Press Ctrl+C to stop."
