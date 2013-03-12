fs   = require 'fs'
url  = require 'url'
path = require 'path'
{ ST, say } = require './server-utils'

beginsWith = (s1, s2) -> s2.substr(0, s1.length) == s1

# TODO errors now cause fs access; make it cache those too! (filesystem doesn't change without restarts anyway)

exports.serveFile = serveFile = (req, res, p, options, cache = {}, headers = {}) ->
    options ?= { root: '.' }
    headers['Content-Type'] ?= if options.mime? then options.mime[(path.extname realfile).substr 1]
    realfile = if options.rewrite then options.rewrite p else p
    [ realroot, realfile ] = [ options.root, "#{options.root}/#{realfile}" ].map path.resolve
    console.log "  real path: #{realfile}"
    if not beginsWith realroot, realfile then say req, res, ST.FORBIDDEN, headers; return
    if cache[realfile]
        console.log "  -> served from cache"
        res.writeHead 200, headers
        res.end cache[realfile]
    else
        fs.stat realfile, (err, stats) ->
            console.log "  -> fs access"
            if err then say req, res, (if err.code == 'ENOENT' then ST.NOT_FOUND else ST.INTERNAL_SERVER_ERROR), headers; return
            if stats.isDirectory() then serveFile req, res, "#{p}/index.html", options, cache; return
            if not stats.isFile() then say req, res, ST.FORBIDDEN, headers; return
            fs.readFile realfile, (err, data) ->
                if err then say req, res, ST.INTERNAL_SERVER_ERROR, headers; return
                cache[realfile] = if options.transform then options.transform p, data else data
                serveFile req, res, p, options, cache

exports.dir = exports.createHandler = (options) ->
    cache = {}
    return serve: (req, res, headers) -> serveFile req, res, (url.parse req.url).pathname, options, cache, headers
