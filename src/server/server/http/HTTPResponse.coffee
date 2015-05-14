_ = require 'lodash'
http = require 'http'
Response = require './../Response'
Headers  = require './Headers'


module.exports = class HTTPResponse extends Response

  ##
  # HTTPResponse constructor.
  #
  # @param {HTTPRequest} req - Reference to associated request object.
  #
  # @param {http.ServerResponse} _res - The raw Node.JS response object.
  #
  # @param {object} [opts] - Options object.
  #
  # @param {string} [opts.errorContent] - Error page content, indexed by status
  # code.
  #
  # @param {string} [opts.defaultErrorMIME='text/plain'] - Default MIME type
  # for error responses.
  #
  # @param {string} [opts.errorMIMEs] - Status-code keyed set of mime types for
  # overriding the default error mime type on a per-code basis.
  #
  # @constructor

  constructor: (req, @_res, @_opts = {}) ->

    @_opts.errorContent ?= {}

    @_opts.defaultErrorMIME ?= 'text/plain'

    @_opts.errorMIMEs ?= {}

    @headers = new Headers @_res
    super req


  ##
  # Sends a response to the client and ends this connection.
  #
  # @param {string|Buffer} [data] - The data to send to the client.
  #
  # @param {string} [encoding='utf8'] - The encoding of the `data` parameter
  # if it is a string.
  #
  # @method send
  # @override
  # @public

  send: (data, encoding = 'utf8') ->

    # Send the response through all the post-middleware. When that is done,
    # the callback function will be executed, assuming no post-middleware
    # terminated the request early.
    @_send data, (data, req, res) =>

      # If we are sending data in the response, try to calculate its length.
      if data

        # If the response is a string, calculate the byte-length.
        if _.isString(data)
          length = Buffer.byteLength data, encoding

        # If the response is a buffer, set the length to the buffer's length.
        else if data instanceof Buffer
          length = data.length

        # If not a string or a Buffer, something is wrong here...
        else
          throw new Error 'Cannot calculate response length.'

        if length then @headers.contentLength = length

      # Write out the headers and response.
      @headers.write()
      @_res.end data, encoding


  ##
  # Sends a 404 response.
  notFound: (data, mime) ->
    @_send4xx 404, data, mime


  ##
  # Sends a 304 response.
  notModified: (data, mime) ->
    @headers.code = 304
    @send(data)



  methodNotAllowed: (data, mime) ->
    @_send4xx 405, data, mime


  internalServerError: (data, mime) ->
    @_send5xx 500, data, mime


  _send4xx: (code, data, mime) ->
    @headers.connection = 'close'
    @headers.code = code
    @headers.mime = mime or @_opts.errorMIMEs[code] or @_opts.defaultErrorMIME
    @send(data or @_opts.errorContent[code] or http.STATUS_CODES[code])


  _send5xx: @.prototype._send4xx


  ##
  # Sends a chunked response to the client. The first call to this method must
  # be called before headers are sent, and will write the headers immediately.
  # `#end()` or `#send()` must be called after the last chunk is written.
  #
  # @param {string|Buffer} data - The data to send to the client.
  #
  # @param {string} [encoding='utf8'] - The encoding of the `data` parameter
  # if it is a string.
  #
  # @method chunk
  # @public

  chunk: (data, encoding = 'utf8') ->
    @_send data, (data, req, res) =>
      if not @headersSent
        @_res.setHeader 'Transfer-Encoding', 'chunked'
        @_res.writeHead 200
      @_res.write data, encoding


  ##
  # Alias for `#send()`.
  #
  # @method end
  # @public

  end: @.prototype.send
