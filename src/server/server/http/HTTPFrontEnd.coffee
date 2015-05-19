
http         = require 'http'
Foundation   = require './../../../common/base/Foundation'
HTTPRequest  = require './HTTPRequest'
HTTPResponse = require './HTTPResponse'



module.exports = class HTTPFrontEnd extends Foundation

  ##
  # The port on-which to accept incomming connections.
  #
  # @property port
  # @default 80
  # @public

  @property 'port',
    default: 80


  ##
  # The hostname to accept incomming connections for. If this is omitted, then
  # the server will accept all incoming connection on the specified port.
  #
  # @see https://nodejs.org/api/http.html#http_server_listen_port_hostname_backlog_callback
  #
  # @property hostname
  # @default null
  # @public

  @property 'hostname',
    default: null


  ##
  # The maximum length of the queue of pending connections. The actual length
  # will be set by the OS.
  #
  # @see https://nodejs.org/api/http.html#http_server_listen_port_hostname_backlog_callback
  #
  # @property backlog
  # @default 500
  # @public

  @property 'backlog',
    default: 500


  @property 'responseOptions',
    default: {}


  @property 'requestOptions',
    default: {}


  ##
  # Creates and returns a new HTTPFrontEnd server front-end.
  #
  # @constructor

  constructor: ->
    super()

    @registerEvents 'request listening close'

    @_http = new http.Server()

    @_http.on 'request', (req, res) =>

      request = new HTTPRequest req
      response = new HTTPResponse request, res, @responseOptions
      @fire 'request',
        request:  request
        response: response

    @_http.on 'close', (req, res) =>
      @fire 'close'

    @_http.on 'listening', =>
      @fire 'listening'

    # @_http.on 'upgrade', ->
    #   console.log 'upgrade!'


  ##
  # Starts the server listening for incoming connections on the configured
  # port and hostname.
  #
  # @method listen
  # @public

  listen: ->
    @_http.listen @port, @hostname, @backlog


  ##
  # Closes the server from accepting new incoming connections.
  #
  # @method close
  # @public

  close: ->
    @_http.close()
