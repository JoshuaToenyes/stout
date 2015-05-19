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


  ##
  # Sends a '307 Temporary Redirect' response.
  #
  # @method temporaryRedirect
  # @public

  temporaryRedirect: (url, data, mime) ->
    @headers.location = url
    @_send3xx 307, data, mime


  ##
  # Sends a '301 Moved Permanently' response.
  #
  # @method permanentRedirect
  # @public

  permanentRedirect: (url, data, mime) ->
    @headers.location = url
    @_send3xx 301, data, mime


  ##
  # Responds with a "Client Error 405 - Method Not Allowed".
  #
  # @param {string} data - The response body.
  #
  # @param {string} mime - The reponse MIME type.
  #
  # @method methodNotAllowed
  # @public

  methodNotAllowed: (data, mime) ->
    @_send4xx 405, data, mime


  ##
  # Responds with a "Internal Server Error 500" response.
  #
  # @param {string} data - The response body.
  #
  # @param {string} mime - The response MIME type.
  #
  # @method internalServerError
  # @public

  internalServerError: (data, mime) ->
    @_send5xx 500, data, mime



  _sendNon200: (code, data, mime) ->
    @headers.code = code
    @headers.mime = mime or @_opts.errorMIMEs[code] or @_opts.defaultErrorMIME
    @send(data or '\r\n')


  ##
  # Sends a 4xx response.
  #
  # @param {number} code - The response status code.
  #
  # @param {string} data - The response body.
  #
  # @param {string} mime - The response MIME type.
  #
  # @method _send4xx
  # @private

  _send4xx: (code, data, mime) ->
    data = data or @_opts.errorContent[code] or http.STATUS_CODES[code]
    @_sendNon200 code, data, mime


  ##
  # Sends a 3xx response.
  #
  # @see _send4xx

  _send3xx: (code, data, mime) ->
    @_sendNon200 code, data, mime


  ##
  # Sends a 5xx response.
  #
  # @see _send4xx

  _send5xx: (code, data, mime) ->
    data = data or @_opts.errorContent[code] or http.STATUS_CODES[code]
    @_sendNon200 code, data, mime


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
