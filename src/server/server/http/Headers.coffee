
_ = require 'lodash'
Foundation  = require './../../../common/base/Foundation'



module.exports = class Headers extends Foundation

  ##
  # HTTP Status Code
  #
  # @property code
  # @default 200
  # @public

  @property 'code',
    default: 200


  ##
  # Connection header, defaults to 'keep-alive'
  #
  # @property connection
  # @public

  @property 'connection',
    set: (c) -> @set 'Connection', c
    default: 'keep-alive'


  ##
  # HTTP status message, which will default to NodeJS's default built-in status
  # message for the appropriate code.
  #
  # @property message
  # @public

  @property 'message'


  ##
  # The MIME type of the response. Sets the Content-Type head to the set value.
  #
  # @property mime
  # @public

  @property 'mime',
    set: (m) -> @set 'Content-Type', m
    default: 'text/plain; charset=utf-8'


  ##
  # the etag header for this response.
  #
  # @property etag
  # @public

  @property 'etag',
    set: (m) -> @set 'ETag', m
    get: -> @get 'ETag'


  ##
  # The expires header for this response.

  @property 'expires',
    set: (d) -> if d then @set 'Expires', d.toUTCString()
    get: -> @get 'Expires'


  ##
  # The maximum age of this response.

  @property 'maxAge',
    set: (m) -> if m then @set 'Cache-Control', "public, max-age=#{m}"
    get: -> @get 'Cache-Control'


  ##
  # Transfer encoding header, which defaults to 'identity'.
  #
  # @property transferEncoding
  # @public

  @property 'transferEncoding',
    set: (c) -> @set 'Transfer-Encoding', c
    get: -> @get 'Transfer-Encoding'
    default: 'identity'


  ##
  # Content-Encoding header.
  #
  # @property contentEncoding
  # @public

  @property 'contentEncoding',
    set: (c) -> @set 'Content-Encoding', c
    get: -> @get 'Content-Encoding'


  ##
  # Content Length of response.
  #
  # @property contentLength
  # @public

  @property 'contentLength',
    set: (l) -> @set 'Content-Length', l


  ##
  # Location field for redirect responses.
  #
  # @property location
  # @public

  @property 'location',
    set: (l) -> @set 'Location', l


  ##
  # Headers constructor. Takes a reference to the corresponding response object.
  #
  # @param {http.ServerResponse} _res - NodeJS response object.
  #
  # @constructor

  constructor: (@_res) ->
    super()
    @sent = false


  ##
  # Sets a header value.
  #
  # @param {string} header - The header to set.
  #
  # @param {string} value - The value to set.
  #
  # @method set
  # @public

  set: (header, value) ->
    if value then @_res.setHeader header, value


  ##
  # Returns the value of the passed header field.
  #
  # @param {string} header - The header to set.
  #
  # @return {string} The value of the set header.
  #
  # @method get
  # @public

  get: (header) ->
    @_res.getHeader header


  ##
  # Writes out the headers.
  #
  # @method write
  # @public

  write: ->
    if @sent then throw new Error 'Headers already sent!'
    @sent = true
    @_res.writeHead @code, @message
