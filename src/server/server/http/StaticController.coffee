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

  ##
  # StaticController constructor. Takes a reference to its parent app or
  # controller and the directory from-which static content should be served.
  #
  # @param {Controller} parent - Parent controller or app.
  #
  # @param {string} serveDirectory - Directory from which static content should
  # be served, relative to the current-working-directory.
  #
  # @constructor

  constructor: (parent, serveDirectory) ->
    super parent

    @_path = path.resolve process.cwd(), serveDirectory

    ##
    # Default MIME types for served file extensions, which can be modified or
    # added to by using classes.
    #
    # @property mimes
    # @public

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


  ##
  # Calculates the ETag for the served file.
  #
  # @method _etag
  # @private

  _etag: (str) ->
    shasum = crypto.createHash 'sha1'
    shasum.update str
    shasum.digest 'hex'


  ##
  # GET handler for static files.
  #
  # @todo - we could add a cache based on the time, etag, or other factors
  # to prevent the requirement of reading from disk on each request.
  #
  # @todo - add logging calls or events.
  #
  # @override
  # @public

  get: (splat, req, res) =>
    self = @

    # Join the requested path and the root static path in the file system
    # to get the asset path.
    ap = path.join @_path, splat

    # Run through this sequence for each request.
    async.waterfall [

      # Read the file stats.
      (cb) -> fs.stat ap, cb

      # Calculate the ETag for this file. If the request includes an
      # "In-None-Match" header then check if the ETag matches. If so, just
      # respond with a `304`.
      (stats, cb) ->
        etag = self._etag stats.mtime.toString()
        if req.headers['if-none-match'] and req.headers['if-none-match'] is etag
          res.notModified()
          cb(null, false)
        else
          res.headers.etag = etag
          res.headers.maxAge = 60
          cb(null, true)

      # `sendFile` will be true if we did not respond with a 304... so the file
      # should be sent to the requestor.
      (sendFile, cb) ->
        if sendFile
          fs.readFile ap, cb
        else
          cb(null, null)

      # Send the file contents to the client, setting the mime type
      # appropriately. If the mime type for this file extension is unknown
      # (i.e. not in the `mimes` property) then the HTTPResponse object will
      # set it to the default value.
      (contents, cb) ->
        if contents is null
          cb(null)
        else
          ext = path.extname(ap).replace '.', ''
          res.headers.mime = self.mimes[ext]
          res.send contents

    ], (er) ->

      # If an error occurred, we should log it and respond with a 404.
      if er
        res.notFound()
