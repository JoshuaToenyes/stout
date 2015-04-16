
http         = require 'http'
Foundation   = require './../../common/base/Foundation'
HTTPRequest  = require './HTTPRequest'
HTTPResponse = require './HTTPResponse'



module.exports = class HTTPFrontEnd extends Foundation

  ##
  #
  # @property port
  # @public

  @property 'port'


  ##
  #
  # @property hostname
  # @public

  @property 'hostname'


  ##
  #
  # @property backlog
  # @public

  @property 'backlog'


  ##
  #
  # @constructor

  constructor: (port, hostname, backlog) ->
    super {
      port: port
      hostname: hostname
      backlog: backlog}

    @registerEvents 'request listening close'

    @_http = new http.Server()

    @_http.on 'request', (req, res) =>
      @fire 'request',
        request:  new HTTPRequest req
        response: new HTTPResponse res

    @_http.on 'close', (req, res) =>
      @fire 'close'

    @_http.on 'listening', =>
      @fire 'listening'


  listen: ->
    @_http.listen @port, @hostname, @backlog


  close: ->
    @_http.close()
