##
#
#
# @fileoverview

_              = require 'lodash'
crypto         = require 'crypto'
async          = require 'async'
fs             = require 'fs'
path           = require 'path'

HTTPController = require './HTTPController'


##
# Static asset handler to easily serve-up static content.
#
# @class StaticController

module.exports = class StaticController extends HTTPController

  constructor: (p) ->
    @_path = path.resolve process.cwd(), p

    @mimes =

      # Image mime types.
      'gif':  'image/gif'
      'jpg':  'image/jpeg'
      'png':  'image/png'
      'bmp':  'image/bmp'
      'svg':  'image/svg+xml'
      'tiff': 'image/tiff'

      # Text-like files.
      'txt':  'text/plain; charset=utf-8'
      'css':  'text/css; charset=utf-8'
      'csv':  'text/csv; charset=utf-8'
      'html': 'text/html; charset=utf-8'
      'rtf':  'text/rtf; charset=utf-8'
      'xml':  'text/xml; charset=utf-8'


  _etag: (str) ->
    shasum = crypto.createHash 'sha1'
    shasum.update str
    shasum.digest 'hex'


  ##
  #
  # @override
  # @public

  get: (splat, req, res) =>
    self = @

    # Join the requested path and the root static path in the file system
    # to get the asset path.
    ap = path.join @_path, splat

    async.waterfall [

      (cb) -> fs.stat ap, cb

      (stats, cb) ->
        etag = self._etag stats.mtime.toString()
        if req.headers['if-none-match'] and req.headers['if-none-match'] is etag
          res.notModified()
          cb(null, false)
        else
          res.headers.etag = etag
          res.headers.maxAge = 60
          cb(null, true)

      (sendFile, cb) ->
        if sendFile
          fs.readFile ap, cb
        else
          cb(null, null)

      (contents, cb) ->
        if contents is null
          cb(null)
        else
          ext = path.extname(ap).replace '.', ''
          res.headers.mime = self.mimes[ext]
          res.send contents

    ], (er) ->
      if er
        res.notFound()
