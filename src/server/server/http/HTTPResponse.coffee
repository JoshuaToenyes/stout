
Response = require './../Response'

module.exports = class HTTPResponse extends Response

  ##
  # Simple boolean property indicating if the headers have already been sent
  # for this response.
  #
  # @property headersSent
  # @public

  @property 'headersSent',
    get: -> @_res.headersSent


  ##
  # HTTPResponse constructor.
  #
  # @param {HTTPRequest} req - Reference to associated request object.
  #
  # @param {http.ServerResponse} _res - The raw Node.JS response object.
  #
  # @constructor

  constructor: (req, @_res) ->
    super req


  ##
  # Sets the header to the specified value. Should only be used before the
  # headers are sent.
  #
  # @param {string} header - The header to set.
  #
  # @param {string|Array<string>} value - The value to set the header to, or
  # an array of string values to set the header to.
  #
  # @method setHeader
  # @public

  setHeader: (header, value) ->
    @_res.setHeader header, value


  ##
  # Sends a response to the client and ends this connection.
  #
  # @param {string|Buffer} data - The data to send to the client.
  #
  # @param {string} [encoding='utf8'] - The encoding of the `data` parameter
  # if it is a string.
  #
  # @method send
  # @override
  # @public

  send: (data = '', encoding = 'utf8') ->
    @_send data, (data, req, res) =>
      @_res.end data, encoding


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
