http    = require 'http'
url     = require 'url'
db      = require './db'
stfiles = require './static-files'
{ ST, say } = require './server-utils'

default_headers = {}

search = db.dir()
files = stfiles.dir
            root: 'client/'
            mime: js: 'application/javascript', html: 'text/html'

server = http.createServer (req, res) ->
    req.parsed_url = url.parse req.url
    switch req.method
        # TODO implement POST (i.e. submit to DB) (eventually)
        when 'GET'
            handler = if req.parsed_url.pathname == '/' and req.parsed_url.search then search else files
            handler.serve req, res, default_headers
        else
            say req, res, ST.METHOD_NOT_ALLOWED, default_headers

server.listen process.env.PORT ? 5000

process.on 'SIGTERM', ->
    console.log 'Shutting down...'
    default_headers['Connection'] = 'close'
    server.close -> console.log 'all connections closed, exiting now'

