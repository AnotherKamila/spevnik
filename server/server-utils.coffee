ST = require 'http-status'

exports.ST = ST

exports.say = say = (req, res, statuscode, headers, message) ->
    headers['Content-Type'] ?= 'text/plain'
    res.writeHead statuscode, headers
    res.end (message ? statuscode+' '+ST[statuscode])+'\n'
