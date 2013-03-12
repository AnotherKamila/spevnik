url = require 'url'
{ ST, say } = require './server-utils'

exports.serveQuery = serveQuery = (req, res, options, cache = {}) ->
    say req, res, ST.OK, 'would serve results for ' + url.parse(req.url).query

exports.dir = exports.createHandler = (options) ->
    cache = {}
    return serve: (req, res) -> serveQuery req, res, options, cache
