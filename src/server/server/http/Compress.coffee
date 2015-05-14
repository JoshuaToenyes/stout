##
# Defines HTTP middleware for compressing responses sent to clients.
#
# @fileoverview

zlib       = require 'zlib'
Middleware = require './../../../common/middleware/Middleware'


##
# HTTP middleware function to compress client responses.
#
# @todo This is a non-conformant parser...
# See http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.3
#
# @class HTTPCompress

module.exports = class HTTPCompress extends Middleware

  constructor: ->

  ##
  #
  # @override
  # @public

  fn: (data, req, res, cb) ->

    acceptEncoding = req.headers['accept-encoding'] or ''

    fn = (er, data) ->
      cb(er, data, req, res)

    # Don't compress anything if there's no data to be compressed. Doing-so
    # will actually create non-zero-length data and lead to a response body.
    if not data
      cb(null, data, req, res)

    else if acceptEncoding.match /\bdeflate\b/
      res.headers.contentEncoding = 'deflate'
      res.headers.transferEncoding = 'deflate'
      zlib.deflate data, fn

    else if acceptEncoding.match /\bgzip\b/
      res.headers.contentEncoding = 'gzip'
      res.headers.transferEncoding = 'gzip'
      zlib.gzip data, fn

    else
      cb(null, data, req, res)
