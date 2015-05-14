
Router        = require './../../../common/route/Router'
HTTPFrontEnd  = require './HTTPFrontEnd'
HTTPRequestRoute = require './HTTPRequestRoute'
Server        = require './../Server'


module.exports = class HTTPServer extends Server

  ##
  # Defines URL routes and handlers.
  #
  # @todo We could define a setter to check that only valid objects are
  # added as the app routes.
  #
  # @property routes
  # @public

  @property 'routes'


  ##
  # Proxy property to set the HTTP server's front-end port.
  #
  # @property port
  # @public

  @property 'port',
    set: (p) ->
      @_frontend.port = p
    get: ->
      return @_frontend.port


  ##
  # HTTPServer constructor.
  #
  # @constructor

  constructor: ->

    # The HTTP server front-end.
    @_frontend = new HTTPFrontEnd

    # The URL router which will route incoming connections.
    @_router = new Router

    super(@_frontend, @_router)

    # If the routes property changes, update the routes.
    @on 'change:routes', @_updateRoutes, @

    # @_frontend.on 'request', -> 
    #
    # @on 'route:matched', (e) ->
    #
    # @on 'route:nomatch', (e) ->


  ##
  # Starts the server accepting new incoming connections.
  #
  # @method start
  # @public

  start: ->
    @_frontend.listen()


  ##
  # Stops the server from accepting new incoming connections.
  #
  # @method stop
  # @public
  stop: ->
    @_frontend.close()


  ##
  # Updates the server's routes by clearing the old routes and re-adding
  # each new route.
  #
  # @method _updateRoutes
  # @private

  _updateRoutes: ->
    @_router.clear()
    for route, handler of @routes
      r = new HTTPRequestRoute route, handler
      @_router.add r
